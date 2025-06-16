from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import mysql.connector
from datetime import datetime

app = FastAPI()

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, cambiar por el dominio del frontend
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Base de datos ---
def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="gestion_equipos"
    )

# --- Modelos ---
class AdminLoginIn(BaseModel):
    usuario: str
    password: str

class DocenteIn(BaseModel):
    nombre: str
    apellido: str
    dni: str

class DocenteOut(DocenteIn):
    id_docente: int

class EquipoIn(BaseModel):
    nombre_equipo: str
    identificador_unico: str
    estado: str = "disponible"

class EquipoOut(EquipoIn):
    id_equipo: int

class MovimientoIn(BaseModel):
    id_equipo: int
    dni: str
    observaciones: str = ""
    curso: str

class DevolucionIn(BaseModel):
    id_movimiento: int

class MantenimientoIn(BaseModel):
    id_equipo: int

class ObservacionIn(BaseModel):
    observaciones: str

# --- ENDPOINTS ---

## 1. Login admin
@app.post("/admin/login/")
def login_admin(data: AdminLoginIn):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM admins WHERE usuario=%s", (data.usuario,))
    admin = cursor.fetchone()
    cursor.close()
    db.close()
    if not admin or admin["password"] != data.password:
        raise HTTPException(status_code=401, detail="Usuario o contraseña incorrectos")
    return {
        "id_admin": admin["id_admin"],
        "nombre": admin["nombre"],
        "apellido": admin["apellido"],
        "usuario": admin["usuario"]
    }

## 2. Docentes CRUD
@app.post("/docentes/", response_model=DocenteOut)
def cargar_docente(docente: DocenteIn):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(
        "INSERT INTO docentes (nombre, apellido, dni) VALUES (%s, %s, %s)",
        (docente.nombre, docente.apellido, docente.dni)
    )
    db.commit()
    id_docente = cursor.lastrowid
    cursor.close()
    db.close()
    return {**docente.dict(), "id_docente": id_docente}

@app.put("/docentes/{id_docente}", response_model=DocenteOut)
def modificar_docente(id_docente: int, docente: DocenteIn):
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        "UPDATE docentes SET nombre=%s, apellido=%s, dni=%s WHERE id_docente=%s",
        (docente.nombre, docente.apellido, docente.dni, id_docente)
    )
    db.commit()
    cursor.close()
    db.close()
    return {**docente.dict(), "id_docente": id_docente}

@app.delete("/docentes/{id_docente}")
def eliminar_docente(id_docente: int):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("DELETE FROM docentes WHERE id_docente=%s", (id_docente,))
    db.commit()
    cursor.close()
    db.close()
    return {"msg": "Docente eliminado"}

@app.get("/docentes/", response_model=list[DocenteOut])
def listar_docentes():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM docentes")
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return result

## 3. Equipos CRUD
@app.post("/equipos/", response_model=EquipoOut)
def cargar_equipo(equipo: EquipoIn):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(
        "INSERT INTO equipos (nombre_equipo, identificador_unico, estado) VALUES (%s, %s, %s)",
        (equipo.nombre_equipo, equipo.identificador_unico, equipo.estado)
    )
    db.commit()
    id_equipo = cursor.lastrowid
    cursor.close()
    db.close()
    return {**equipo.dict(), "id_equipo": id_equipo}

@app.put("/equipos/{id_equipo}", response_model=EquipoOut)
def modificar_equipo(id_equipo: int, equipo: EquipoIn):
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        "UPDATE equipos SET nombre_equipo=%s, identificador_unico=%s, estado=%s WHERE id_equipo=%s",
        (equipo.nombre_equipo, equipo.identificador_unico, equipo.estado, id_equipo)
    )
    db.commit()
    cursor.close()
    db.close()
    return {**equipo.dict(), "id_equipo": id_equipo}

@app.delete("/equipos/{id_equipo}")
def eliminar_equipo(id_equipo: int):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("DELETE FROM equipos WHERE id_equipo=%s", (id_equipo,))
    db.commit()
    cursor.close()
    db.close()
    return {"msg": "Equipo eliminado"}

@app.get("/equipos/", response_model=list[EquipoOut])
def listar_equipos():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM equipos")
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return result

## 4. Movimientos - Retirar equipo
@app.post("/movimientos/retirar/")
def retirar_equipo(movimiento: MovimientoIn):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    # Buscar docente por DNI
    cursor.execute("SELECT id_docente FROM docentes WHERE dni=%s", (movimiento.dni,))
    docente = cursor.fetchone()
    if not docente:
        cursor.close()
        db.close()
        raise HTTPException(404, "Docente no encontrado")
    # Verificar que el equipo esté disponible
    cursor.execute("SELECT estado FROM equipos WHERE id_equipo=%s", (movimiento.id_equipo,))
    equipo = cursor.fetchone()
    if not equipo or equipo["estado"] != "disponible":
        cursor.close()
        db.close()
        raise HTTPException(400, "Equipo no disponible para retiro")
    # Registrar movimiento, con curso
    cursor.execute(
        "INSERT INTO movimientos (id_equipo, id_docente, fecha_hora_retiro, observaciones, curso) VALUES (%s, %s, %s, %s, %s)",
        (movimiento.id_equipo, docente["id_docente"], datetime.now(), movimiento.observaciones, movimiento.curso)
    )
    cursor.execute(
        "UPDATE equipos SET estado='prestado' WHERE id_equipo=%s",
        (movimiento.id_equipo,)
    )
    db.commit()
    cursor.close()
    db.close()
    return {"msg": "Equipo retirado correctamente"}

## 5. Movimientos - Devolver equipo
@app.post("/movimientos/devolver/")
def devolver_equipo(devolucion: DevolucionIn):
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        "SELECT id_equipo FROM movimientos WHERE id_movimiento=%s AND fecha_hora_devolucion IS NULL",
        (devolucion.id_movimiento,)
    )
    movimiento = cursor.fetchone()
    if not movimiento:
        cursor.close()
        db.close()
        raise HTTPException(404, "Movimiento no encontrado o ya devuelto")
    cursor.execute(
        "UPDATE movimientos SET fecha_hora_devolucion=%s WHERE id_movimiento=%s",
        (datetime.now(), devolucion.id_movimiento)
    )
    cursor.execute(
        "UPDATE equipos SET estado='disponible' WHERE id_equipo=%s",
        (movimiento[0],)
    )
    db.commit()
    cursor.close()
    db.close()
    return {"msg": "Equipo devuelto correctamente"}

## 6. Movimientos - Marcar mantenimiento
@app.post("/equipos/mantenimiento/")
def marcar_mantenimiento(data: MantenimientoIn):
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        "UPDATE equipos SET estado='mantenimiento' WHERE id_equipo=%s",
        (data.id_equipo,)
    )
    db.commit()
    cursor.close()
    db.close()
    return {"msg": "Equipo marcado como en mantenimiento"}

## 7. Movimientos - Actualizar observaciones
@app.put("/movimientos/{id_movimiento}")
def actualizar_movimiento(id_movimiento: int, datos: ObservacionIn):
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        "UPDATE movimientos SET observaciones=%s WHERE id_movimiento=%s",
        (datos.observaciones, id_movimiento)
    )
    db.commit()
    cursor.close()
    db.close()
    return {"msg": "Movimiento actualizado"}

## 8. Historial de movimientos
@app.get("/movimientos/", response_model=list)
def ver_historial():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT m.id_movimiento,
               m.id_equipo,
               e.nombre_equipo,
               e.identificador_unico,
               e.estado,
               d.nombre AS nombre_docente,
               d.apellido AS apellido_docente,
               m.fecha_hora_retiro,
               m.fecha_hora_devolucion,
               m.observaciones,
               m.curso
        FROM movimientos m
        JOIN equipos e ON m.id_equipo = e.id_equipo
        JOIN docentes d ON m.id_docente = d.id_docente
        ORDER BY m.fecha_hora_retiro DESC
    """)
    movimientos = cursor.fetchall()
    cursor.close()
    db.close()
    return movimientos
