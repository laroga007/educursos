"""
EduCursos - Carga y validación de datos con SQLAlchemy

Lee las actualizaciones semanales (alumnos desde una API en JSON e
inscripciones desde un CSV), valida cada registro y lo inserta en la base.
Los registros que no pasan la validación, o que la base rechaza por sus
restricciones, se guardan en la tabla load_errors: nada se pierde sin aviso.

Uso (desde la carpeta educursos, con el entorno virtual activo):
    export EDUCURSOS_DB_PASSWORD='tu_contraseña'
    python carga/cargar_datos.py
"""

import csv
import json
import os
from datetime import datetime
from pathlib import Path

from sqlalchemy import create_engine, event, text
from sqlalchemy.engine import URL
from sqlalchemy.exc import DBAPIError

DATA_DIR = Path(__file__).resolve().parent.parent / "data"


# ---------------------------------------------------------------
# 1) Conexión: create_engine es el único punto que cambia de motor
# ---------------------------------------------------------------
# PostgreSQL es el motor de producción de EduCursos. Para usar otro motor
# alcanza con definir la variable EDUCURSOS_DB_URL, por ejemplo:
#   SQL Server: mssql+pyodbc://sa:CLAVE@localhost:1433/educursos?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes
#   MySQL:      mysql+pymysql://root:CLAVE@localhost:3306/educursos
#   SQLite:     sqlite:///sqlite/educursos.db
# El resto del script no cambia.

def crear_motor():
    url = os.getenv("EDUCURSOS_DB_URL")
    if not url:
        password = os.getenv("EDUCURSOS_DB_PASSWORD")
        if not password:
            raise SystemExit(
                "Falta la contraseña de la base. Antes de correr el script, escribí en la Terminal:\n"
                "    export EDUCURSOS_DB_PASSWORD='tu_contraseña'"
            )
        # URL.create arma la dirección y se ocupa de los caracteres especiales (como @)
        url = URL.create(
            "postgresql+psycopg2",
            username="postgres",
            password=password,
            host="localhost",
            port=5432,
            database="educursos",
        )

    engine = create_engine(url)

    # SQLite no controla las claves foráneas salvo que se active en cada conexión
    if engine.dialect.name == "sqlite":
        @event.listens_for(engine, "connect")
        def activar_claves_foraneas(conexion, _):
            conexion.execute("PRAGMA foreign_keys = ON")

    return engine


# ---------------------------------------------------------------
# 2) Lectura de las fuentes
# ---------------------------------------------------------------

def leer_alumnos_api(ruta):
    """Lee el JSON que devuelve la API y se queda con la lista de alumnos."""
    with open(ruta, encoding="utf-8") as archivo:
        respuesta = json.load(archivo)
    return respuesta["alumnos"]


def leer_inscripciones_csv(ruta):
    """Lee el CSV. Los números llegan como texto: se convierten a entero."""
    with open(ruta, newline="", encoding="utf-8") as archivo:
        filas = list(csv.DictReader(archivo))
    for fila in filas:
        for campo in ("subscription_id", "user_id", "course_id"):
            if fila[campo] != "":
                fila[campo] = int(fila[campo])
    return filas


# ---------------------------------------------------------------
# 3) Validación previa (lo que conviene revisar antes de llegar a la base)
# ---------------------------------------------------------------

def es_fecha_valida(valor):
    try:
        datetime.strptime(valor, "%Y-%m-%d")
        return True
    except (TypeError, ValueError):
        return False


def validar(registro, obligatorios, campos_fecha):
    """Devuelve el motivo del rechazo, o None si el registro está bien."""
    faltantes = [campo for campo in obligatorios if registro.get(campo) in (None, "")]
    if faltantes:
        return "Faltan datos obligatorios: " + ", ".join(faltantes)
    for campo in campos_fecha:
        if not es_fecha_valida(registro[campo]):
            return f"Fecha inválida en {campo}: {registro[campo]}"
    return None


# ---------------------------------------------------------------
# 4) Carga: un registro por vez, cada uno en su propia transacción
# ---------------------------------------------------------------

def registrar_error(engine, fuente, registro, motivo):
    with engine.begin() as conexion:
        conexion.execute(
            text("INSERT INTO load_errors (source, record, error_message) "
                 "VALUES (:source, :record, :error_message)"),
            {"source": fuente,
             "record": json.dumps(registro, ensure_ascii=False),
             "error_message": motivo},
        )


def cargar(engine, registros, sql_insert, obligatorios, campos_fecha, fuente):
    cargados, rechazados = 0, 0
    for registro in registros:
        motivo = validar(registro, obligatorios, campos_fecha)
        if motivo is None:
            try:
                # engine.begin() abre una transacción: si el INSERT falla,
                # se deshace sola y la base queda como estaba
                with engine.begin() as conexion:
                    conexion.execute(text(sql_insert), registro)
                cargados += 1
                continue
            except DBAPIError as error:
                # La base rechazó el registro por una restricción
                # (clave foránea, UNIQUE, clave primaria repetida...)
                motivo = "La base rechazó el registro: " + str(error.orig).splitlines()[0]
        registrar_error(engine, fuente, registro, motivo)
        rechazados += 1
    print(f"{fuente}: {cargados} cargados, {rechazados} enviados a load_errors")


# ---------------------------------------------------------------
# 5) Ejecución
# ---------------------------------------------------------------

def main():
    engine = crear_motor()
    print(f"Conectada a {engine.dialect.name}\n")

    # Primero los alumnos: las inscripciones nuevas pueden depender de ellos
    cargar(
        engine,
        leer_alumnos_api(DATA_DIR / "actualizaciones_api.json"),
        "INSERT INTO users (user_id, name, email, registration_date) "
        "VALUES (:user_id, :name, :email, :registration_date)",
        obligatorios=["user_id", "name", "email", "registration_date"],
        campos_fecha=["registration_date"],
        fuente="actualizaciones_api.json",
    )

    cargar(
        engine,
        leer_inscripciones_csv(DATA_DIR / "inscripciones_nuevas.csv"),
        "INSERT INTO subscriptions (subscription_id, user_id, course_id, subscription_date) "
        "VALUES (:subscription_id, :user_id, :course_id, :subscription_date)",
        obligatorios=["subscription_id", "user_id", "course_id", "subscription_date"],
        campos_fecha=["subscription_date"],
        fuente="inscripciones_nuevas.csv",
    )

    # Resumen final
    with engine.connect() as conexion:
        for tabla in ("users", "subscriptions", "load_errors"):
            filas = conexion.execute(text(f"SELECT COUNT(*) FROM {tabla}")).scalar()
            print(f"  {tabla}: {filas} filas")


if __name__ == "__main__":
    main()
