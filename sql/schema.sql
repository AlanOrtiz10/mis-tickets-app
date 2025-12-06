-- ============================================================================
-- ESQUEMA DE BASE DE DATOS PARA MISTICKETS
-- ============================================================================
-- Este archivo contiene la definición del esquema de base de datos para
-- la aplicación MisTickets, incluyendo tablas y políticas de seguridad RLS
-- (Row Level Security) para proteger los datos de cada usuario.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TABLA: tickets
-- ----------------------------------------------------------------------------
-- Almacena la información de los tickets/recibos de cada usuario
-- Cada ticket pertenece a un usuario específico (user_id)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tickets (
  -- Identificador único del ticket (UUID generado automáticamente)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Monto del ticket (número decimal con 2 decimales de precisión)
  -- Ejemplo: 150.50, 2500.00
  monto DECIMAL(10, 2) NOT NULL CHECK (monto >= 0),

  -- Categoría del gasto (texto variable hasta 100 caracteres)
  -- Ejemplos: "Alimentos", "Transporte", "Educación", "Entretenimiento"
  categoria VARCHAR(100) NOT NULL,

  -- Fecha del ticket (fecha y hora completa con zona horaria)
  -- Se establece automáticamente a la fecha actual si no se proporciona
  fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- URL de la foto del ticket almacenada en Supabase Storage
  -- Puede ser NULL si el usuario no subió foto
  url_foto TEXT,

  -- ID del usuario propietario del ticket
  -- Referencia al usuario autenticado en Supabase Auth
  -- UUID que identifica de forma única a cada usuario
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Marca de tiempo de creación del registro
  -- Se establece automáticamente al crear el ticket
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Marca de tiempo de última actualización del registro
  -- Se actualiza automáticamente cuando se modifica el ticket
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- ÍNDICES PARA OPTIMIZAR CONSULTAS
-- ----------------------------------------------------------------------------
-- Índice para acelerar búsquedas por usuario
-- Las consultas filtrando por user_id serán mucho más rápidas
CREATE INDEX IF NOT EXISTS idx_tickets_user_id ON tickets(user_id);

-- Índice para acelerar búsquedas por fecha
-- Útil para reportes y filtros por rango de fechas
CREATE INDEX IF NOT EXISTS idx_tickets_fecha ON tickets(fecha DESC);

-- Índice para acelerar búsquedas por categoría
-- Útil para agrupar gastos por categoría
CREATE INDEX IF NOT EXISTS idx_tickets_categoria ON tickets(categoria);

-- ----------------------------------------------------------------------------
-- FUNCIÓN PARA ACTUALIZAR AUTOMÁTICAMENTE updated_at
-- ----------------------------------------------------------------------------
-- Esta función se ejecuta automáticamente antes de cada UPDATE
-- para mantener actualizada la marca de tiempo de modificación

CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  -- Establece updated_at a la fecha/hora actual
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que ejecuta la función antes de cada UPDATE
CREATE TRIGGER trigger_actualizar_updated_at
  BEFORE UPDATE ON tickets
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_updated_at();

-- ----------------------------------------------------------------------------
-- POLÍTICAS DE SEGURIDAD RLS (Row Level Security)
-- ----------------------------------------------------------------------------
-- RLS garantiza que cada usuario solo pueda acceder a sus propios tickets
-- Esto protege la privacidad y seguridad de los datos financieros
-- ----------------------------------------------------------------------------

-- Habilitar Row Level Security en la tabla tickets
-- Esto activa el sistema de políticas de seguridad
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

-- POLÍTICA: Los usuarios solo pueden VER sus propios tickets
-- Cuando un usuario hace SELECT, solo obtiene registros donde user_id = su ID
CREATE POLICY "Los usuarios pueden ver solo sus propios tickets"
  ON tickets
  FOR SELECT
  USING (auth.uid() = user_id);

-- POLÍTICA: Los usuarios solo pueden INSERTAR tickets para sí mismos
-- Cuando un usuario hace INSERT, el user_id debe ser su propio ID
CREATE POLICY "Los usuarios pueden crear tickets solo para sí mismos"
  ON tickets
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- POLÍTICA: Los usuarios solo pueden ACTUALIZAR sus propios tickets
-- Cuando un usuario hace UPDATE, solo puede modificar registros donde user_id = su ID
CREATE POLICY "Los usuarios pueden actualizar solo sus propios tickets"
  ON tickets
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- POLÍTICA: Los usuarios solo pueden ELIMINAR sus propios tickets
-- Cuando un usuario hace DELETE, solo puede borrar registros donde user_id = su ID
CREATE POLICY "Los usuarios pueden eliminar solo sus propios tickets"
  ON tickets
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- NOTAS DE SEGURIDAD:
-- ============================================================================
-- 1. RLS está HABILITADO: Ningún usuario puede acceder a datos de otros usuarios
-- 2. Las políticas usan auth.uid(): Función de Supabase que retorna el ID del
--    usuario autenticado actualmente
-- 3. ON DELETE CASCADE: Si se elimina un usuario, todos sus tickets se eliminan
--    automáticamente para mantener la integridad referencial
-- 4. CHECK (monto >= 0): Garantiza que no se ingresen montos negativos
-- 5. TIMESTAMPTZ: Almacena fechas con zona horaria para consistencia global
-- ============================================================================
