CREATE OR REPLACE PROCEDURE insertar_domicilio(
    _id_domicilio INT,
    _direccion_dom VARCHAR,
    _fecha_alta_dom DATE,
    _fecha_baja_dom DATE,
    _id_baja INT,
    _id_tipo_dom INT,
    _id_formato_fact INT,
    _id_estructura INT,
	_id_cuenta INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si se ha proporcionado la dirección
    IF _direccion_dom IS NULL OR _direccion_dom = '' THEN
        -- Actualizar datos en la tabla accion si no se proporciona la dirección
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'No se informa la dirección',
			fecha_ejecucion_ini = current_date,
			fecha_ejecucion_fin = current_date
        WHERE id_accion = 1; -- Utilizamos _id_domicilio como referencia
    ELSE
        -- Verificar si se ha proporcionado id_estructura
        IF _id_estructura IS NULL THEN
            -- Actualizar datos en la tabla accion si no se proporciona id_estructura
            UPDATE accion
            SET id_estado_accion = 1,
                comentarios = 'No se informa estructura del pais',
				fecha_ejecucion_ini = current_date,
				fecha_ejecucion_fin = current_date
            WHERE id_accion = 1; -- Utilizamos _id_domicilio como referencia
        ELSE
            -- Verificar si se ha proporcionado id_tipo_dom
            IF _id_tipo_dom IS NULL THEN
                -- Actualizar datos en la tabla accion si no se proporciona id_tipo_dom
                UPDATE accion
                SET id_estado_accion = 1,
                    comentarios = 'No se informa el tipo de domicilio',
					fecha_ejecucion_ini = current_date,
					fecha_ejecucion_fin = current_date
                WHERE id_accion = 1; -- Utilizamos _id_domicilio como referencia
            ELSE
                -- Verificar si id_formato_fact es nulo
                IF _id_formato_fact IS NULL THEN
                    -- Actualizar datos en la tabla accion si no se proporciona id_formato_fact
                    UPDATE accion
                    SET id_estado_accion = 1,
                        comentarios = 'No se informa formato de factura',
                        fecha_ejecucion_ini = current_date,
                        fecha_ejecucion_fin = current_date
                    WHERE id_accion = 1;
                ELSE
                    -- Verificar si la cuenta existe
                    PERFORM 1 FROM cuenta WHERE id_cuenta = _id_cuenta;
                    IF NOT FOUND THEN
                        -- Actualizar datos en la tabla accion si la cuenta no existe
                        UPDATE accion
                        SET id_estado_accion = 1,
                            comentarios = 'La cuenta proporcionada no existe',
                            fecha_ejecucion_ini = current_date,
                            fecha_ejecucion_fin = current_date
                        WHERE id_accion = 1;
                    ELSE
                        -- Insertar en la tabla si todas las condiciones son satisfactorias
                        INSERT INTO domicilio (
                            id_domicilio,
                            direccion_dom,
                            fecha_alta_dom,
                            fecha_baja_dom,
                            id_baja,
                            id_tipo_dom,
                            id_formato_fact,
                            id_estructura,
                            id_cuenta
                        ) VALUES (
                            _id_domicilio,
                            _direccion_dom,
                            _fecha_alta_dom,
                            _fecha_baja_dom,
                            _id_baja,
                            _id_tipo_dom,
                            _id_formato_fact,
                            _id_estructura,
                            _id_cuenta
                        );
                        
                        -- Actualizar datos en la tabla accion para indicar éxito
                        UPDATE accion
                        SET id_estado_accion = 3,
                            comentarios = 'Domicilio creado correctamente',
                            fecha_ejecucion_ini = current_date,
                            fecha_ejecucion_fin = current_date
                        WHERE id_accion = 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END;
$$;

--

CREATE OR REPLACE PROCEDURE insertar_articulo_por_domicilio(
    _id_articulo INT,
    _id_domicilio INT,
	_num_imsi INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si se ha proporcionado la dirección
    IF _id_articulo IS NULL AND _id_domicilio IS NULL THEN
        -- Actualizar datos en la tabla accion si no se proporciona 
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'No se informa articulo'
        WHERE id_accion = 2; 
    ELSE
        -- Verificar si se ha proporcionado id_estructura
        IF _id_articulo IS NOT NULL AND _id_domicilio IS NULL THEN
            -- Actualizar datos en la tabla accion si no se proporciona id_estructura
            UPDATE accion
            SET id_estado_accion = 1,
                comentarios = 'No se informa domicilio'
            WHERE id_accion = 2; -- Utilizamos _id_domicilio como referencia
        ELSE
            -- Verificar si se ha proporcionado id_tipo_dom
            IF _id_baja IS NOT NULL THEN
                -- Actualizar datos en la tabla accion si no se proporciona id_tipo_dom
                UPDATE accion
                SET id_estado_accion = 1,
                    comentarios = 'El domicilio está de baja y no se puede realizar la acción'
                WHERE id_accion = 2; -- Utilizamos _id_domicilio como referencia
            ELSE
                -- Insertar en la tabla si todas las condiciones son satisfactorias
                INSERT INTO articulo_por_domicilio (
                    id_articulo,
                    id_domicilio,
                    num_imsi
                ) VALUES (
					_id_articulo ,
					_id_domicilio,	
					_num_imsi 
                );
                
                -- Actualizar datos en la tabla accion para indicar éxito
                UPDATE accion
                SET id_estado_accion = 3,
                    comentarios = 'Articulo creado correctamente',
					fecha_ejecucion_ini = current_date,
					fecha_ejecucion_fin = current_date
                WHERE id_accion = 2;
            END IF;
        END IF;
    END IF;
END;
$$;

--PARA DAR DE ALTA UN ARTICULO

CREATE OR REPLACE PROCEDURE dar_alta_articulo_en_domicilio1(
    _id_articulo INT,
    _id_domicilio INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si el artículo ya está asociado al domicilio
    IF EXISTS (
        SELECT 1
        FROM articulo_por_domicilio
        WHERE id_articulo = _id_articulo AND id_domicilio = _id_domicilio
    ) THEN
        -- Actualizar datos en la tabla accion si el artículo ya está asociado al domicilio
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'El domicilio ya tiene activo el mismo artículo',
			fecha_ejecucion_ini = current_date,
			fecha_ejecucion_fin = current_date
        WHERE id_accion = 2; -- Utilizamos _id_articulo como referencia
    ELSE
        -- Insertar en la tabla articulo_por_domicilio si el artículo no está asociado al domicilio
        INSERT INTO articulo_por_domicilio (id_articulo, id_domicilio)
        VALUES (_id_articulo, _id_domicilio);
        
        -- Actualizar datos en la tabla accion para indicar éxito
        UPDATE accion
        SET id_estado_accion = 3,
            comentarios = 'Artículo dado de alta correctamente en el domicilio',
			fecha_ejecucion_ini = current_date,
			fecha_ejecucion_fin = current_date
        WHERE id_accion = 2; -- Utilizamos _id_articulo como referencia
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE dar_alta_articulo_en_domicilio2(
    _id_articulo INT,
    _id_domicilio INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _id_plan INT;
BEGIN
    -- Obtener el id_plan asociado al domicilio
    SELECT id_plan INTO _id_plan
    FROM cuenta
    JOIN planes_atencion ON cuenta.id_plan = planes_atencion.id_plan
    WHERE cuenta.id_domicilio = _id_domicilio;

    -- Verificar si el artículo está configurado en el plan
    IF NOT EXISTS (
        SELECT 1
        FROM precio
        WHERE id_precio = _id_plan AND id_articulo = _id_articulo
    ) THEN
        -- Actualizar datos en la tabla accion si el artículo no está configurado en el plan
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'El artículo no está configurado en el plan del domicilio',
			fecha_ejecucion_ini = current_date,
			fecha_ejecucion_fin = current_date
        WHERE id_accion = 2; -- Utilizamos _id_articulo como referencia
    ELSE
        -- Insertar en la tabla articulo_por_domicilio
        INSERT INTO articulo_por_domicilio (id_articulo, id_domicilio)
        VALUES (_id_articulo, _id_domicilio);
        
        -- Actualizar datos en la tabla accion para indicar éxito
        UPDATE accion
        SET id_estado_accion = 3,
            comentarios = 'Artículo dado de alta correctamente en el domicilio',
			fecha_ejecucion_ini = current_date,
			fecha_ejecucion_fin = current_date
        WHERE id_accion = 2; -- Utilizamos _id_articulo como referencia
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE dar_alta_articulo_en_domicilio3(
    _id_articulo INT,
    _id_domicilio INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _id_plan INT;
BEGIN
    -- Obtener el id_plan asociado al domicilio
    SELECT id_plan INTO _id_plan
    FROM cuenta
    JOIN planes_atencion ON cuenta.id_plan = planes_atencion.id_plan
    WHERE cuenta.id_domicilio = _id_domicilio;

    -- Verificar si el artículo está configurado como opcional en el plan
    IF EXISTS (
        SELECT 1
        FROM precio
        WHERE id_precio = _id_plan AND id_articulo = _id_articulo
    ) THEN
        -- Verificar si el artículo ya está registrado para el domicilio
        IF NOT EXISTS (
            SELECT 1
            FROM articulo_por_domicilio
            WHERE id_articulo = _id_articulo AND id_domicilio = _id_domicilio
        ) THEN
            -- Insertar en la tabla articulo_por_domicilio
            INSERT INTO articulo_por_domicilio (id_articulo, id_domicilio)
            VALUES (_id_articulo, _id_domicilio);

            -- Actualizar datos en la tabla accion para indicar éxito
            UPDATE accion
            SET id_estado_accion = 3,
                comentarios = 'Artículo dado de alta y activado correctamente en el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 3; -- Utilizamos _id_articulo como referencia
        ELSE
            -- Actualizar datos en la tabla accion si el artículo ya está registrado para el domicilio
            UPDATE accion
            SET id_estado_accion = 1,
                comentarios = 'El artículo ya está registrado para el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 3; -- Utilizamos _id_articulo como referencia
        END IF;
    ELSE
        -- Actualizar datos en la tabla accion si el artículo no está configurado como opcional en el plan
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'El artículo no está configurado como opcional en el plan del domicilio',
            fecha_ejecucion_ini = current_date,
            fecha_ejecucion_fin = current_date
        WHERE id_accion = 3; -- Utilizamos _id_articulo como referencia
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE dar_alta_articulo_en_domicilio4(
    _id_articulo INT,
    _id_domicilio INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _id_plan INT;
    _monto_activacion INT;
BEGIN
    -- Obtener el id_plan asociado al domicilio
    SELECT id_plan INTO _id_plan
    FROM cuenta
    JOIN planes_atencion ON cuenta.id_plan = planes_atencion.id_plan
    WHERE cuenta.id_domicilio = _id_domicilio;

    -- Verificar si el artículo está configurado como opcional en el plan
    IF EXISTS (
        SELECT 1
        FROM precio
        WHERE id_precio = _id_plan AND id_articulo = _id_articulo
    ) THEN
        -- Verificar si el artículo ya está registrado para el domicilio
        IF NOT EXISTS (
            SELECT 1
            FROM articulo_por_domicilio
            WHERE id_articulo = _id_articulo AND id_domicilio = _id_domicilio
        ) THEN
            -- Calcular el monto de activación (puedes ajustar la lógica según tus necesidades)
            _monto_activacion := 50; -- Ejemplo, puedes ajustar este valor

            -- Insertar en la tabla articulo_por_domicilio
            INSERT INTO articulo_por_domicilio (id_articulo, id_domicilio)
            VALUES (_id_articulo, _id_domicilio);

            -- Actualizar datos en la tabla accion para indicar éxito
            UPDATE accion
            SET id_estado_accion = 3,
                comentarios = 'Artículo dado de alta y activado correctamente en el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 4; -- Utilizamos _id_articulo como referencia

            -- Registrar el monto a pagar para la siguiente factura
            INSERT INTO precio (monto, id_estructura, fecha_inicio_precio, fecha_fin_precio)
            VALUES (_monto_activacion, _id_domicilio, current_date, NULL);
        ELSE
            -- Actualizar datos en la tabla accion si el artículo ya está registrado para el domicilio
            UPDATE accion
            SET id_estado_accion = 1,
                comentarios = 'El artículo ya está registrado para el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 4; -- Utilizamos _id_articulo como referencia
        END IF;
    ELSE
        -- Actualizar datos en la tabla accion si el artículo no está configurado como opcional en el plan
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'El artículo no está configurado como opcional en el plan del domicilio',
            fecha_ejecucion_ini = current_date,
            fecha_ejecucion_fin = current_date
        WHERE id_accion = 4; -- Utilizamos _id_articulo como referencia
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE dar_alta_pack_en_domicilio5(
    _id_pack INT,
    _id_domicilio INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar si el pack está configurado como opcional al plan
    IF EXISTS (
        SELECT 1
        FROM articulo_pack
        WHERE id_articulo_pack = _id_pack
    ) THEN
        -- Verificar si el pack ya está registrado para el domicilio
        IF NOT EXISTS (
            SELECT 1
            FROM articulo_por_domicilio
            WHERE id_articulo = _id_pack AND id_domicilio = _id_domicilio
        ) THEN
            -- Insertar en la tabla articulo_por_domicilio
            INSERT INTO articulo_por_domicilio (id_articulo, id_domicilio)
            VALUES (_id_pack, _id_domicilio);

            -- Actualizar datos en la tabla accion para indicar éxito
            UPDATE accion
            SET id_estado_accion = 3,
                comentarios = 'Pack dado de alta y activado correctamente en el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 5; -- Utilizamos _id_pack como referencia
        ELSE
            -- Actualizar datos en la tabla accion si el pack ya está registrado para el domicilio
            UPDATE accion
            SET id_estado_accion = 1,
                comentarios = 'El pack ya está registrado para el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 5; -- Utilizamos _id_pack como referencia
        END IF;
    ELSE
        -- Actualizar datos en la tabla accion si el pack no está configurado como opcional
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'El pack no está configurado como opcional al plan',
            fecha_ejecucion_ini = current_date,
            fecha_ejecucion_fin = current_date
        WHERE id_accion = 5; -- Utilizamos _id_pack como referencia
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE dar_alta_pack_con_precio6(
    _id_pack INT,
    _id_domicilio INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    _monto_pack NUMERIC;
BEGIN
    -- Obtener el monto del pack desde la tabla precio
    SELECT monto INTO _monto_pack
    FROM precio
    WHERE id_articulo = _id_pack
      AND fecha_inicio_precio <= current_date
      AND (fecha_fin_precio IS NULL OR fecha_fin_precio >= current_date);

    -- Verificar si el pack está configurado como opcional al plan
    IF EXISTS (
        SELECT 1
        FROM articulo_pack
        WHERE id_articulo_pack = _id_pack
    ) THEN
        -- Verificar si el pack ya está registrado para el domicilio
        IF NOT EXISTS (
            SELECT 1
            FROM articulo_por_domicilio
            WHERE id_articulo = _id_pack AND id_domicilio = _id_domicilio
        ) THEN
            -- Insertar en la tabla articulo_por_domicilio
            INSERT INTO articulo_por_domicilio (id_articulo, id_domicilio)
            VALUES (_id_pack, _id_domicilio);

            -- Actualizar datos en la tabla accion para indicar éxito
            UPDATE accion
            SET id_estado_accion = 3,
                comentarios = 'Pack dado de alta y activado correctamente en el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 5; -- Utilizamos _id_pack como referencia

            -- Registrar el monto a pagar por la activación del pack para la siguiente factura
            INSERT INTO monto_a_pagar (id_domicilio, monto, fecha_inicio, id_articulo)
            VALUES (_id_domicilio, _monto_pack, current_date, _id_pack);
        ELSE
            -- Actualizar datos en la tabla accion si el pack ya está registrado para el domicilio
            UPDATE accion
            SET id_estado_accion = 1,
                comentarios = 'El pack ya está registrado para el domicilio',
                fecha_ejecucion_ini = current_date,
                fecha_ejecucion_fin = current_date
            WHERE id_accion = 5; -- Utilizamos _id_pack como referencia
        END IF;
    ELSE
        -- Actualizar datos en la tabla accion si el pack no está configurado como opcional
        UPDATE accion
        SET id_estado_accion = 1,
            comentarios = 'El pack no está configurado como opcional al plan',
            fecha_ejecucion_ini = current_date,
            fecha_ejecucion_fin = current_date
        WHERE id_accion = 5; -- Utilizamos _id_pack como referencia
    END IF;
END;
$$;
