import datetime
from quart import Quart, request, jsonify, render_template
from quart_cors import cors
from telethon.sync import TelegramClient, functions, types
from telethon.tl.functions.channels import GetFullChannelRequest
from telethon.sessions import StringSession
from telethon.tl.functions.messages import AddChatUserRequest
import os
import aiofiles
import sqlite3
import random
import hashlib

icon_colors = [0x6FB9F0, 0xFFD67E, 0xCB86DB, 0x8EEE98, 0xFF93B2, 0xFB6F5F]

app = Quart(__name__)
app = cors(app)  # Habilita CORS para todas las rutas

api_id = 24182212
api_hash = 'f375f3e2c8e1f5b47639379c7b654c8c'

# Conecta o crea la base de datos
# Conectarse a la base de datos o crearla si no existe
conn = sqlite3.connect('./tgpersonalcloud.db')

# Crea un cursor para ejecutar comandos SQL
cursor = conn.cursor()

# Crer la tabla 'usuario'
cursor.execute('''
    CREATE TABLE IF NOT EXISTS user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        string_session TEXT NOT NULL UNIQUE,
        phone_number TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL UNIQUE
    )
''')

# Crear la tabla 'channel'
cursor.execute('''
    CREATE TABLE IF NOT EXISTS channel (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        users INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user(id)
    )
''')

# Crear la tabla 'topic'
cursor.execute('''
CREATE TABLE IF NOT EXISTS topic (
        id INTEGER,
        channel_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        color TEXT NOT NULL,
        FOREIGN KEY (channel_id) REFERENCES channel(id)         
    )
''')

# Crear la tabla 'right'
cursor.execute('''
CREATE TABLE IF NOT EXISTS right (
        channel_id INTEGER,
        contact_id INTEGER,
        send_messages BOOLEAN,
        send_media BOOLEAN,
        send_stickers BOOLEAN,
        send_gifs BOOLEAN,
        send_games BOOLEAN,
        send_inline BOOLEAN,
        embed_link BOOLEAN,
        send_polls BOOLEAN,
        change_info BOOLEAN,
        invite_users BOOLEAN,
        pin_messages BOOLEAN,
        FOREIGN KEY (channel_id) REFERENCES channel(id),
        FOREIGN KEY (contact_id) REFERENCES contact(id)
    )
''')

# Crear la tabla 'contact'
cursor.execute('''
CREATE TABLE IF NOT EXISTS contact (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        first_name TEXT,
        last_name TEXT,
        user_name TEXT UNIQUE,
        phone_number TEXT UNIQUE
    )
''')

# Guarda los cambios y cierra la conexión
conn.commit()
conn.close()

@app.route("/")
async def index():
    return await render_template("index.html")

# --- DATABASE MANAGEMENT FUNCTIONS --------------------------------------------------------------------------------------------------------------------
# Function to insert a user's session information into the database
def insert_user_into_database(string_session, phone_number, password):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        password = hashlib.sha256(password.encode()).hexdigest()

        # Insert user session data into the 'sessions' table
        cursor.execute("INSERT INTO user (string_session, phone_number, password) VALUES (?, ?, ?)",
                       (string_session, phone_number, password))

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # Return True to indicate successful insertion
        return True
    except sqlite3.Error as e:
        # Handle any errors that occur during the insertion process
        print("Error inserting into the database:", e)
        return False

# Function to insert a user's session information into the database
def insert_password_into_database(phone_number, password):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # password = hashlib.sha256(password.encode()).hexdigest()

        cursor.execute("SELECT id FROM user WHERE phone_number = ?", (phone_number,))

        result = cursor.fetchone()

        user_id = result[0]

        print("ID", result, user_id)

        # Insert user session data into the 'sessions' table
        cursor.execute("UPDATE user SET password = ? WHERE id = ?",
                       (password, user_id))

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # Return True to indicate successful insertion
        return True
    except sqlite3.Error as e:
        # Handle any errors that occur during the insertion process
        print("Error inserting into the database:", e)
        return False

#################################################################################################################################
# CHANNELS
def insert_channel(id, user_id, title, desc):
    print("CREANDO CANAL")
    try:
        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Datos que deseas insertar en la tabla channels
        channel_data = (id, user_id, title, desc, 1)

        # Sentencia SQL para insertar datos en la tabla channels
        insert_query = '''
        INSERT INTO channel (id, user_id, title, description, users)
        VALUES (?, ?, ?, ?, ?);
        '''

        # Ejecutar la sentencia SQL
        cursor.execute(insert_query, channel_data)

        # Guardar los cambios en la base de datos
        conn.commit()

        print("CANAL CREADO")
    except Exception as e:
        print("Fallo al crear el canal", e)

    # Cerrar la conexión
    conn.close()

def update_channel_title(id, title, about):
    try:
        import sqlite3

        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Sentencia SQL para la actualización
        update_query = '''
        UPDATE channel
        SET title = ?,
        description = ?
        WHERE id = ?;
        '''

        # Ejecutar la sentencia SQL con los valores proporcionados
        cursor.execute(update_query, (title, about, id))

        # Guardar los cambios en la base de datos
        conn.commit()
    except Exception as e:
        print("Fallo al editar el canal", e)

    # Cerrar la conexión
    conn.close()

def update_channel_users(id, users):
    try:
        import sqlite3

        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Sentencia SQL para la actualización
        update_query = '''
        UPDATE channel
        SET users = ?
        WHERE id = ?;
        '''

        # Ejecutar la sentencia SQL con los valores proporcionados
        cursor.execute(update_query, (users, id))

        # Guardar los cambios en la base de datos
        conn.commit()
    except Exception as e:
        print("Fallo al editar los usuarios", e)

    # Cerrar la conexión
    conn.close()

def delete_channel_db(id):
    try:
        import sqlite3

        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Sentencia SQL para la actualización
        update_query = '''
        DELETE FROM channel
        WHERE id = ?;
        '''

        # Ejecutar la sentencia SQL con los valores proporcionados
        cursor.execute(update_query, (id,))

        # Sentencia SQL para la actualización
        update_query = '''
        DELETE FROM right
        WHERE channel_id = ?;
        '''

        # Ejecutar la sentencia SQL con los valores proporcionados
        cursor.execute(update_query, (id,))

        # Sentencia SQL para la actualización
        update_query = '''
        DELETE FROM topic
        WHERE channel_id = ?;
        '''

        # Ejecutar la sentencia SQL con los valores proporcionados
        cursor.execute(update_query, (id,))

        # Guardar los cambios en la base de datos
        conn.commit()
    except Exception as e:
        print("Fallo al eliminar el canal", e)

    # Cerrar la conexión
    conn.close()

def delete_topic_db(topic_id, channel_id):
    try:
        import sqlite3

        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Sentencia SQL para la actualización
        update_query = '''
        DELETE FROM topic
        WHERE id = ? AND channel_id = ?;
        '''

        # Ejecutar la sentencia SQL con los valores proporcionados
        cursor.execute(update_query, (topic_id, channel_id,))

        # Guardar los cambios en la base de datos
        conn.commit()
    except Exception as e:
        print("Fallo al eliminar el topic", e)

    # Cerrar la conexión
    conn.close()

#################################################################################################################################
# TOPICS
def insert_topic(id, channel_id, title, color):
    print("CREANDO CANAL")
    try:
        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Datos que deseas insertar en la tabla channels
        channel_data = (id, channel_id, title, color)

        # Sentencia SQL para insertar datos en la tabla channels
        insert_query = '''
        INSERT INTO topic (id, channel_id, title, color)
        VALUES (?, ?, ?, ?);
        '''

        # Ejecutar la sentencia SQL
        cursor.execute(insert_query, channel_data)

        # Guardar los cambios en la base de datos
        conn.commit()

        print("CANAL CREADO")
    except Exception as e:
        print("Fallo al crear el canal", e)

    # Cerrar la conexión
    conn.close()
#################################################################################################################################

def insert_rights(channel_id, contact_id, send_messages, send_media, send_stickers, send_gifs,
                  send_games, send_inline, embed_link_previews, send_polls, change_info, invite_users, pin_messages):
    print("CREANDO RIGHT")
    try:
        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Datos que deseas insertar en la tabla rights
        rights_data = (channel_id, contact_id, send_messages, send_media, send_stickers, send_gifs,
                       send_games, send_inline, embed_link_previews, send_polls, change_info, invite_users, pin_messages)

        # Sentencia SQL para insertar datos en la tabla rights
        insert_query = '''
        INSERT INTO right (channel_id, contact_id, send_messages, send_media, send_stickers, send_gifs,
            send_games, send_inline, embed_link, send_polls, change_info, invite_users, pin_messages)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        '''

        # Ejecutar la sentencia SQL
        cursor.execute(insert_query, rights_data)

        # Guardar los cambios en la base de datos
        conn.commit()

        print("RIGHT CREADO")
    except Exception as e:
        print("FALLO AL CREAR EL RIGHT", e)

    # Cerrar la conexión
    conn.close()

def update_rights(channel_id, contact_id, selected_permissions):
    try:
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Actualizar las columnas excepto los IDs a 0
        cursor.execute('''
            UPDATE right
            SET send_messages = 0,
                send_media = 0,
                send_stickers = 0,
                send_gifs = 0,
                send_games = 0,
                send_inline = 0,
                embed_link = 0,
                send_polls = 0,
                change_info = 0,
                invite_users = 0,
                pin_messages = 0
                WHERE channel_id = ? AND contact_id = ?
        ''', (channel_id, contact_id,))
        for permission in selected_permissions:
            print(permission)
            update_query = f'''
            UPDATE right
            SET {permission} = 1
            WHERE channel_id = ? AND contact_id = ?
            '''
            cursor.execute(update_query, (channel_id, contact_id,))


        # Guarda los cambios en la base de datos
        conn.commit()

        # Cierra la conexión
        conn.close()
            
        # Return True to indicate successful insertion
        return True
    except sqlite3.Error as e:
        # Handle any errors that occur during the insertion process
        print("Error inserting into the database:", e)
        return False




# Function to retrieve a user's session string by their phone number
def get_string_session_from_database(phone_number):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Retrieve the session string from the 'sessions' table based on phone number
        cursor.execute("SELECT string_session FROM user WHERE phone_number=?", (phone_number,))
        result = cursor.fetchone()

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # If a result is found, return the session string; otherwise, return None
        if result:
            string_session = result[0]
            return string_session
        else:
            return None

    except Exception as e:
        # Handle any errors that occur during the database query
        print(f"Error querying the database: {str(e)}")
        return None
    
def select_user_id_from_user(phone_number):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Retrieve the session string from the 'sessions' table based on phone number
        cursor.execute("SELECT id FROM user WHERE phone_number=?", (phone_number,))
        result = cursor.fetchone()

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # If a result is found, return the session string; otherwise, return None
        if result:
            user_id = result[0]
            return user_id
        else:
            return None

    except Exception as e:
        # Handle any errors that occur during the database query
        print(f"Error querying the database: {str(e)}")
        return None
    
def select_contact_id_from_contact(contact_id):
    print(contact_id)
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Retrieve the session string from the 'sessions' table based on phone number
        cursor.execute("SELECT * FROM contact WHERE id=?", (contact_id,))
        result = cursor.fetchone()

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # If a result is found, return the session string; otherwise, return None
        if result:
            user_id = result[0]
            return user_id
        else:
            return None

    except Exception as e:
        # Handle any errors that occur during the database query
        print(f"Error querying the database: {str(e)}")
        return None


# Function to check if a user with a given phone number exists in the database
def check_user_from_database(phone_number):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Count the number of records with the specified phone number in the 'sessions' table
        cursor.execute("SELECT COUNT(*) FROM user WHERE phone_number=?", (phone_number,))
        count = cursor.fetchone()[0]

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # If the count is greater than 0, the user exists; otherwise, they do not
        if count > 0:
            return True
        else:
            return False

    except Exception as e:
        # Handle any errors that occur during the database query
        print(f"Error checking user existence in the database: {str(e)}")
        return False
    
# Function to check if a user with a given phone number exists in the database
def check_user_from_database_password(phone_number):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Count the number of records with the specified phone number in the 'sessions' table
        cursor.execute("SELECT password FROM user WHERE phone_number=?", (phone_number,))
        result = cursor.fetchone()[0]

        print("RESULT", result)
        print(hashlib.sha256("".encode()).hexdigest())

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # If the count is greater than 0, the user exists; otherwise, they do not
        if result != hashlib.sha256("".encode()).hexdigest():
            print("true")
            return True
        else:
            print("false")
            return False

    except Exception as e:
        # Handle any errors that occur during the database query
        print(f"Error checking user existence in the database: {str(e)}")
        return False

# Function to check if a given password matches the password stored for a user's phone number
def check_password_from_database(phone_number, password):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Retrieve the stored password from the 'sessions' table based on phone number
        cursor.execute("SELECT password FROM user WHERE phone_number=?", (phone_number,))
        result = cursor.fetchone()

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()

        # If a result is found, compare the stored password with the provided password
        if result:
            stored_password = result[0]
            if password == stored_password:
                return True
            else:
                return False
        else:
            return False

    except Exception as e:
        # Handle any errors that occur during the database query
        print(f"Error checking the password in the database: {str(e)}")
        return False
# ------------------------------------------------------------------------------------------------------------------------------------------------------

# --- USER LOGIN FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------
# Create dictionaries to store client and phone number data
clients = {}

# Endpoint to handle sending a phone number to Telegram
# This endpoint expects a POST request with JSON data containing a 'phone_number' field.
@app.route('/send_phone_number', methods=['POST'])
async def send_phone_number():
    data = await request.get_json()
    phone_number = data['phone_number']

    print(phone_number)
    if check_user_from_database(phone_number):
        print("DENTRO")
        return jsonify({'message': 'User already exists in database.'}), 200
    else:
        print("FUERA")
        # Create a Telegram client object with a string session
        client = TelegramClient(StringSession(), api_id, api_hash)

        # Connect to the Telegram service
        await client.connect()

        # Check if the user is authorized; if not, send a code request to the phone number
        if not await client.is_user_authorized():
            try:
                await client.send_code_request(phone_number)

                # Store the client object in the 'clients' dictionary
                clients[phone_number] = client
            except:
                print("The phone number is invalid.")
                return jsonify({'message': 'The phone number is invalid'}), 777

        return jsonify({'message': 'User does not exists in database.'}), 500
    
# Endpoint to handle sending a verification code
# This endpoint expects a POST request with JSON data containing 'code' and 'phone_number' fields.
@app.route('/send_verification_code', methods=['POST'])
async def send_verification_code():
    data = await request.get_json()
    code = data['code']
    phone_number = data['phone_number']
    
    # Check if the user exists in the database
    if check_user_from_database(phone_number):
        print("The user already exists in the database")
        # Return a JSON response indicating that the number is already registered
        return jsonify({'message': 'This number has already been registered'}), 200
    else:
        print("User does not exists in the database")

        # If the user doesn't exist, retrieve the client object from the 'clients' dictionary
        client = clients.get(phone_number)

        # Connect the client and sign in with the code
        await client.connect()

        try:
            await client.sign_in(phone_number, code)
        except:
            print("This code is invalid.")
            return jsonify({'message': 'This code is invalid.'}), 777

        # Save the client's string session and insert user data into the database
        string_session = client.session.save()

        if insert_user_into_database(string_session, phone_number, ""):
            print("Record inserted successfully into the database without password")
        else:
            print("Error inserting the record into the database")
        # Return a JSON response indicating that the number is not registered
        return jsonify({'message': 'This number is not registered'}), 500

# Endpoint to handle sending a password and code
# This endpoint expects a POST request with JSON data containing 'code', 'phone_number', and 'password' fields.
@app.route('/send_password', methods=['POST'])
async def send_password():
    data = await request.get_json()
    code = data['code']
    phone_number = data['phone_number']
    password = data['password']

    print(code, phone_number, password)

    # Check if the user exists in the database
    if check_user_from_database(phone_number):        
        if check_user_from_database_password(phone_number):
            print(password)
            # If the user exists, check the password from the database
            password = hashlib.sha256(password.encode()).hexdigest()
            if check_password_from_database(phone_number, password):
                # If the password matches, create a Telegram client with a saved session and return success
                string_session = get_string_session_from_database(phone_number)
                client = TelegramClient(StringSession(string_session), api_id, api_hash)
                
                await client.connect()

                return jsonify({'message': 'Logged in successfully'}), 200
            else:
                return jsonify({'message': 'Password incorrect.'}), 500
        else:
            print(password)
            password = hashlib.sha256(password.encode()).hexdigest()
            print(password)
            insert_password_into_database(phone_number, password)

            # Return a JSON response indicating that a user has been created
            return jsonify({'message': 'User updated'}), 200

# ------------------------------------------------------------------------------------------------------------------------------------------------------




########################################################################
# USER
async def getInfo(client):
    await client.connect()
    me = await client.get_me()
    print(me)
    try:
        user_info = {
            "id": me.id,
            "nombre": me.first_name,
            "apellido": me.last_name,
            "username": me.username,
            "phone": me.phone
        }
        return user_info
    except Exception as e:
        print(e)
    
@app.route('/get_user_info', methods=['POST'])
async def get_user_info():
    data = await request.get_json()
    phone_number = data['phone_number']
    print("DENTRO", phone_number)
    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)


    await client.connect()

    print(string_session, client)

    
    me = await client.get_me()
    print(me)
    user_info = {
        "id": me.id,
        "nombre": me.first_name,
        "apellido": me.last_name,
        "username": me.username,
        "phone": me.phone
    }
    
    print(user_info)
    return jsonify(user_info)
########################################################################

@app.route('/log_out', methods=['POST'])
async def log_out():
    try:
        data = await request.get_json()
        phone_number = data['phone_number']
        string_session = get_string_session_from_database(phone_number)
        client = TelegramClient(StringSession(string_session), api_id, api_hash)

        await client.connect()

        if client:
            await client.log_out()
            return "Se ha cerrado la sesión", 200
    except:
        return "No se ha cerrado la sesión", 500



@app.route('/get_messages', methods=['POST'])
async def get_messages():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    topic_id = data['topic_id']

    messages = []

    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)
    
    await client.connect()

    try: 
        async for message in client.iter_messages(int(channel_id), reply_to=int(topic_id)):
            message_data = {'text': None, 'file_size': None}
            
            if message.text is not None and message.text.strip() != "":
                # print(f"Mensaje de texto: {message.text}")
                message_data['text'] = message.text

            if message.media and message.file.size is not None:
                tamaño_del_archivo = message.file.size
                # print(f"Tamaño del archivo adjunto: {tamaño_del_archivo} bytes")
                message_data['file_size'] = tamaño_del_archivo

            # Agregar el diccionario al conjunto solo si tiene valores
            if message_data:
                messages.append(message_data)
        
        # Devuelve los mensajes en formato JSON, incluyendo el texto y el tamaño del archivo
        return jsonify({'messages': messages}), 200
    except:
        return 'Error obteniendo los mensajes', 500
    

@app.route('/delete_messages', methods=['POST'])
async def delete_messages():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    topic_id = data['topic_id']


    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()
    
    try: 
        async for message in client.iter_messages(int(channel_id), reply_to=int(topic_id)):            
            if message.text is not None:
                try:
                    await client(functions.channels.DeleteMessagesRequest(int(channel_id),[message.id]))
                except Exception as e:
                    print(e)
                                
        # Devuelve los mensajes en formato JSON, incluyendo el texto y el tamaño del archivo
        return "Mensajes eliminados", 200
    except:
        return 'Error obteniendo los mensajes', 500

@app.route('/check_authorization', methods=['POST'])
async def check_authorization():
    data = await request.get_json()
    phone_number = data['phone_number']

    if check_user_from_database(phone_number):
        return jsonify({'authorized': True}), 200
    else:
        return jsonify({'authorized': False}), 500


@app.route('/send_message/<phone_number>', methods=['POST'])
async def send_message(phone_number):
    phone_number = "+" + phone_number
    data = await request.get_json()
    message = data['message']
    # await send_message_to_telegram(message, phone_number)
    return jsonify({'message': 'Mensaje enviado correctamente'}), 200
    
@app.route('/upload/<group_id>/<phone_number>', methods=['POST'])
async def upload_file(group_id, phone_number):
    phone_number = "+" + phone_number
    file = (await request.files).get('file')
    if file:
        filename = file.filename
        content_type = file.content_type

        # Crear y escribir el contenido del archivo en la ubicación actual
        async with aiofiles.open(filename, 'wb') as f:
            await f.write(file.read())  # No se utiliza 'await' aquí

        # Enviar el archivo a Telegram
        await send_file_to_telegram(filename, group_id, phone_number)

        # Borrar el archivo local
        try:
            os.remove(filename)
        except Exception as e:
            print(f"No se pudo eliminar el archivo local: {e}")

        return 'Archivo enviado a Telegram con éxito y archivo local eliminado', 200
    else:
        return 'Error al enviar el archivo', 400
    
# Función para enviar un archivo a Telegram
async def send_file_to_telegram(filename, group_id, phone_number):
    phone_number = "+" + phone_number
    try:
        string_session = get_string_session_from_database(phone_number)
        client = TelegramClient(StringSession(string_session), api_id, api_hash)

        await client.connect()
        
        # Enviar el archivo con los atributos especificados
        await client.send_file(int(group_id), filename, caption=filename)
    except Exception as e:
        print(f"No se pudo enviar el archivo {filename}.")

@app.route('/send_media_topic/<group_id>/<topic_id>/<phone_number>/<file_size>', methods=['POST'])
async def send_media_topic(group_id, topic_id, phone_number, file_size):
    phone_number = "+" + phone_number
    file = (await request.files).get('file')
    if file:
        filename = file.filename

        # Crear y escribir el contenido del archivo en la ubicación actual
        async with aiofiles.open(filename, 'wb') as f:
            await f.write(file.read())  # No se utiliza 'await' aquí

        # Enviar el archivo a Telegram
        await send_file_to_telegram_topic(filename, group_id, topic_id, phone_number, file_size)

        # Borrar el archivo local
        try:
            os.remove(filename)
        except Exception as e:
            print(f"No se pudo eliminar el archivo local: {e}")

        return 'Archivo enviado a Telegram con éxito y archivo local eliminado', 200
    else:
        return 'Error al enviar el archivo', 400
    
# Función para enviar un archivo a Telegram
async def send_file_to_telegram_topic(filename, group_id, topic_id, phone_number, file_size_file):
    try:
        string_session = get_string_session_from_database(phone_number)
        client = TelegramClient(StringSession(string_session), api_id, api_hash)

        # Crear el atributo DocumentAttributeFileSize con el tamaño del archivo
        # attributes.append(types.DocumentAttributeFileSize(file_size))

        # Printing upload progress
        def callback(current, total):
            print('Uploaded', current, 'out of', total,'bytes: {:.2%}'.format(current / total))

        await client.connect()

        # Crear el atributo DocumentAttributeFilename con el nombre del archivo
        attributes = [types.DocumentAttributeFilename(file_name=str(filename))]

        await client.send_file(int(group_id), filename, caption=filename, reply_to=int(topic_id), silent=True, attributes=attributes, file_size=len(file_size_file), progress_callback=callback, force_document=True)
    except Exception as e:
        print(f"No se pudo enviar el archivo {filename}. {e}")


def select_channels(user_id):
    channels = []
    try:
        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Ejecutar la sentencia SQL
        cursor.execute("SELECT * FROM channel WHERE user_id = ?", (user_id,))

        rows = cursor.fetchall()

        for row in rows:
            channels.append({
                'id': row[0],
                'title': row[2],
                'desc' : row[3],
                'users': row[4]
            })   

        return channels
    except Exception as e:
        print("Fallo al obtener los canales", e)

    # Cerrar la conexión
    conn.close()

@app.route('/get_channels', methods=['POST'])
async def get_channels():
    channels = []
    data = await request.get_json()
    phone_number = data['phone_number']

    user_id = select_user_id_from_user(phone_number)

    channels = select_channels(user_id)


    '''
    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    dialogs = await client.get_dialogs()
    channels = []

    for dialog in dialogs:
        if dialog.is_group and dialog.title.startswith("::") and dialog.title.endswith("::") and dialog.title != ":::PersonalCloud:::":
            ch = await client.get_entity(dialog.id)
            ch_full = await client(GetFullChannelRequest(channel=ch)) 
            channel_info = {
                'id': dialog.id,
                'title': dialog.title.replace("::", ""),
                'desc': ch_full.full_chat.about
            }
            channels.append(channel_info)
            update_channel_users(dialog.id, ch_full.full_chat.participants_count)
    '''

    return jsonify({'channels': channels})

def select_topics(channel_id):
    topics = []
    try:
        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Ejecutar la sentencia SQL
        cursor.execute("SELECT * FROM topic WHERE channel_id = ?", (channel_id,))

        rows = cursor.fetchall()

        for row in rows:
            topics.append({
                'id': row[0],
                'title': row[2],
                'color' : row[3]
            })   

        return topics
    except Exception as e:
        print("Fallo al obtener los usuarios", e)

    # Cerrar la conexión
    conn.close()

@app.route('/get_topics', methods=['POST'])
async def get_topics():
    topics = []
    data = await request.get_json()
    phone_number = data['phone_number']
    id = data['id']

    topics = select_topics(id)

    # string_session = get_string_session_from_database(phone_number)
    # client = TelegramClient(StringSession(string_session), api_id, api_hash)

    # await client.connect()

    # for topic_id in range(1, 31):
    #     result = await client(functions.channels.GetForumTopicsByIDRequest(
    #         channel=int(id),
    #         topics=[topic_id]
    #     ))

    #     if result.count > 0 and isinstance(result.topics[0], types.ForumTopic):
    #         topics.append({
    #             'id': result.topics[0].id,
    #             'title': result.topics[0].title,
    #             'color' : result.topics[0].icon_color
    #         })    
    return jsonify({'topics': topics})

@app.route('/delete_topic', methods=['POST'])
async def delete_topic():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    topic_id = data['topic_id']

    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    await client(functions.channels.DeleteTopicHistoryRequest(
        channel=int(channel_id), top_msg_id=int(topic_id)))
    
    delete_topic_db(int(topic_id), int(channel_id))
    
    # Devolver una respuesta de éxito
    return "Eliminado con éxito", 200

@app.route('/create_topic', methods=['POST'])
async def create_topic():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    title = data['title']

    color = random.choice(icon_colors)
    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    result = await client(functions.channels.CreateForumTopicRequest(
        channel=int(channel_id),
        title=title,
        icon_color=color
    ))

    result_id = result.updates[0].id

    insert_topic(result_id, channel_id, title, color)

    # Devolver una respuesta de éxito
    return "Creado con éxito", 200



def insert_user_right(channel_id, user_id):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Insert user session data into the 'sessions' table
        cursor.execute("INSERT INTO 'right' ('channel_id', 'user_id', 'send_messages', 'send_media', 'send_stickers', 'send_gifs', 'send_games', 'send_inline', 'embed_link', 'send_polls', 'change_info', 'invite_users', 'pin_messages') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                       (int(channel_id), int(user_id), False, False, False, False, False, False, False, False, False, False, False))

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()
    except sqlite3.Error as e:
        # Handle any errors that occur during the insertion process
        print("Error inserting into the database:", e)

def insert_user_db(contact_id, user_id, user_first_name, user_last_name, user_user_name, user_phone_number):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Insert user session data into the 'sessions' table
        cursor.execute("INSERT INTO contact (id, user_id, first_name, last_name, user_name, phone_number) VALUES (?, ?, ?, ?, ?, ?)",
                       (int(contact_id), int(user_id), user_first_name, user_last_name, user_user_name, user_phone_number))

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()
    except sqlite3.Error as e:
        # Handle any errors that occur during the insertion process
        print("Error inserting into the database:", e)

@app.route('/insert_contact', methods=['POST'])
async def insert_contact():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    contact_id = data['contact_id']

    string_session = get_string_session_from_database(phone_number)
    user_id = select_user_id_from_user(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    try:
        try:
            user = await client(functions.users.GetFullUserRequest(id=contact_id))
        except:
            user = await client(functions.users.GetFullUserRequest(id=int(contact_id)))
        if user.users:
            for u in user.users:
                await client(functions.channels.InviteToChannelRequest(
                    channel=int(channel_id),
                    users=[u]
                ))
                try:
                    is_contact_in_db = select_contact_id_from_contact(int(u.id))
                    if (is_contact_in_db == None):
                        insert_user_db(u.id, user_id, u.first_name, u.last_name, u.username, str("+" + u.phone))
                except Exception as e:
                    print(e)
                    return {"error": e}, 500
                
                insert_rights(channel_id, u.id, True, True, True, True, True, True, True, True, True, True, True)
                # insert_user_right(channel_id, u.id)
            return "Insertado con exito", 200
    except Exception as e:
        error_message = "Error al insertar: " + str(e)
        print(error_message)
        return {"error": error_message}, 500
    
def delete_contact_db(channel_id, contact_id):
    try:
        # Connect to the './tgpersonalcloud.db' SQLite database
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Insert user session data into the 'sessions' table
        cursor.execute("DELETE FROM contact WHERE id = ?",
                       (int(contact_id),))
        
        cursor.execute("DELETE FROM right WHERE channel_id = ? AND contact_id = ?", (int(channel_id), int(contact_id)),)

        # Commit the transaction and close the database connection
        conn.commit()
        conn.close()
    except sqlite3.Error as e:
        # Handle any errors that occur during the insertion process
        print("Error deleting into the database:", e)

@app.route('/delete_contact', methods=['POST'])
async def delete_contact():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    contact_id = data['contact_id']

    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    try:
        await client.edit_permissions(
            entity=int(channel_id),
            user=int(contact_id),
            view_messages=False
        )

        delete_contact_db(channel_id, contact_id)
        return 'Eliminado con exito', 200
    except Exception as e:
        error_message = "Error al borrar: " + str(e)
        print(error_message)
        return {"error": error_message}, 500



def select_users(user_id, channel_id):
    users = []
    try:
        # Conectar a la base de datos
        conn = sqlite3.connect('./tgpersonalcloud.db')
        cursor = conn.cursor()

        # Ejecutar la sentencia SQL
        cursor.execute("SELECT * FROM contact WHERE user_id = ?", (user_id,))

        # Ejecuta la consulta SQL
        cursor.execute('''
            SELECT contact.*
            FROM contact
            JOIN right ON contact.id = right.contact_id
            WHERE right.channel_id = ? AND contact.user_id = ?
        ''', (channel_id, user_id,))

        rows = cursor.fetchall()

        for row in rows:
            users.append({
                'id': row[0],
                'first_name': row[2],
                'last_name': row[3],
                'user_name': row[4],
                'phone_number': row[5]
            })

        return users
    except Exception as e:
        print("Fallo al obtener los usuarios", e)

    # Cerrar la conexión
    conn.close()
    
@app.route('/get_contacts', methods=['POST'])
async def get_contacts():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']

    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    user_id = select_user_id_from_user(phone_number)

    users = select_users(user_id, channel_id)
    
    # Devolver una respuesta de éxito
    return jsonify({'users': users})

def select_rights(channel_id, user_id):
    rightsGranted = []
    rights = []

    # Conectar a la base de datos
    conn = sqlite3.connect('./tgpersonalcloud.db')
    cursor = conn.cursor()

    # Obtener los nombres de las columnas de la tabla 'right'
    cursor.execute('PRAGMA table_info(right)')
    columns = [row[1] for row in cursor.fetchall()]

    # Crear una lista para almacenar los nombres de las columnas con valor 1

    # Realizar la consulta para verificar el valor de cada columna
    for column in columns[2:]:  # Excluimos las dos primeras columnas (channel_id y user_id)
        cursor.execute(f'''
        SELECT {column}
        FROM right
        WHERE channel_id = ?
        AND contact_id = ?
        ''', (channel_id, user_id))

        result = cursor.fetchone()
        if result[0] == True:
            rightsGranted.append(column)
        else:
            rights.append(column)
    # Cerrar la conexión
    conn.close()
    return rightsGranted, rights



@app.route('/get_rights', methods=['POST'])
async def get_rights():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    contact_id = data['contact_id']

    rights = select_rights(channel_id, contact_id)
    rightsGranted = rights[0]
    rightsRevoked = rights[1]
    
    # Devolver una respuesta de éxito
    return jsonify({'rightsGranted': rightsGranted, 'rightsRevoked': rightsRevoked})

@app.route('/send_rights', methods=['POST'])
async def send_rights():
    data = await request.get_json()
    phone_number = data['phone_number']
    channel_id = data['channel_id']
    contact_id = data['user_id']
    selected_rights = data['selected_rights']

    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    # Set all rights to False initially
    permissions = {
        'view_messages': True,
        'send_messages': False,
        'send_media': False,
        'send_stickers': False,
        'send_gifs': False,
        'send_games': False,
        'send_inline': False,
        'embed_link_previews': False,  # Use the correct name expected by the method
        'send_polls': False,
        'change_info': False,
        'invite_users': False,
        'pin_messages': False,
    }

    # Map the names from your database to the names expected by the method
    mapping = {
        'embed_link': 'embed_link_previews',
    }

    # Set the selected rights to True
    for right in selected_rights:
        permissions[mapping.get(right, right)] = True

    # Alternatively, you can use edit_permissions directly
    await client.edit_permissions(
        entity=int(channel_id),
        user=int(contact_id),
        **permissions
    )

    update_rights(channel_id, contact_id, selected_rights)

    # Devolver una respuesta de éxito
    return "Datos recibidos", 200


# FOLDERS
async def get_next_available_folder_id(client):
    result = await client(functions.messages.GetDialogFiltersRequest())
    existing_ids = {dialog_filter.id for dialog_filter in result if isinstance(dialog_filter, types.DialogFilter)}
    
    next_available_id = max(existing_ids, default=0) + 1
    
    return next_available_id

async def check_folder_tgpc(client):
    result = await client(functions.messages.GetDialogFiltersRequest())
    for dialog_filter in result:
        if isinstance(dialog_filter, types.DialogFilter):
            if dialog_filter.title == "TGPC":
                return dialog_filter.id
    return 0

async def create_folder(client, id, title, chat_id):
    chat = await client.get_input_entity(chat_id)

    folder = types.DialogFilter(
        id = id,
        title = title,
        pinned_peers=[],
        include_peers=[chat],
        exclude_peers=[],
    )
    
    result = await client(functions.messages.UpdateDialogFilterRequest(
        id = folder.id,
        filter = folder
    ))

async def add_group_to_folder(client, id, chat_id):
    chat_list = await get_input(client, await get_folder_peers_id(client, id))

    chat = await client.get_input_entity(chat_id)
    chat_list.append(chat)

    folder = types.DialogFilter(
        id = id,
        title = "TGPC",
        pinned_peers=[],
        include_peers=chat_list,
        exclude_peers=[],
    )
    
    result = await client(functions.messages.UpdateDialogFilterRequest(
        id = folder.id,
        filter = folder
    ))

async def get_folder_peers_id(client, id):
    result = await client(functions.messages.GetDialogFiltersRequest())
    for dialog_filter in result:
        if isinstance(dialog_filter, types.DialogFilter):
            if dialog_filter.id == id:
                # MIRAR SI LOS GRUPOS TODAVIA EXISTEN
                include_peers = dialog_filter.include_peers
                peer_ids = [peer.channel_id for peer in include_peers if isinstance(peer, types.InputPeerChannel)]
                return peer_ids

async def get_input(client, ids):
    chat_list = []

    for id in ids:
        chat = None
        new_id = int("-100" + str(id))
        try:
            chat = await client.get_input_entity(new_id)
        except Exception as e:
            try:
                if id in chat_list:
                    chat_list.remove(id)
            except Exception as e:
                print("REMOVE", e)
        
        if chat is not None:
            chat_list.append(chat)

    return chat_list

async def check_group_name(client, title):
    dialogs = await client.get_dialogs()

    for dialog in dialogs:
        if dialog.is_group and dialog.title == title:
            return True
    return False

@app.route('/create_channel', methods=['POST'])
async def create_channel():
    data = await request.get_json()
    phone_number = data['phone_number']
    title = data['title']
    title = "::"+title+"::"
    desc = data['desc']

    string_session = get_string_session_from_database(phone_number)
    user_id = select_user_id_from_user(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    if await check_group_name(client, title):
        return "Canal duplicado", 500
    else:
        channel = await client(functions.channels.CreateChannelRequest(
            title=title,
            about=desc,
            megagroup=True,
            forum=True
        ))

        channel_id = "-100" + str(channel.chats[0].id)
        folder_id = await check_folder_tgpc(client)

        insert_channel(channel_id, user_id, title.replace("::", ""), desc)

        if folder_id != 0:
            await add_group_to_folder(client, folder_id, int(channel_id))
        else:
            next_folder_id = await get_next_available_folder_id(client)
            await create_folder(client, next_folder_id, "TGPC", int(channel_id))

        try:
            await client(functions.messages.EditChatDefaultBannedRightsRequest(
                peer=int(channel_id),
                banned_rights=types.ChatBannedRights(
                    until_date=None,
                    view_messages=False,
                    send_messages=False,
                    send_media=False,
                    send_stickers=False,
                    send_gifs=False,
                    send_games=False,
                    send_inline=False,
                    send_polls=False,
                    change_info=False,
                    invite_users=False,
                    pin_messages=False,
                    manage_topics=False,
                    send_photos=False,
                    send_videos=False,
                    send_roundvideos=False,
                    send_audios=False,
                    send_voices=False,
                    send_docs=False,
                    send_plain=False
                )
            ))
        except Exception as e:
            print(e)

        # Devolver una respuesta de éxito
        return "Canal creado con éxito", 200
    
@app.route('/edit_channel', methods=['POST'])
async def edit_channel():
    data = await request.get_json()
    phone_number = data['phone_number']
    id = data['id']
    title = "::" + data['title'] + "::"
    about = data['about']

    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    channel = await client.get_entity(id)

    await client(functions.channels.EditTitleRequest(channel=id,title=title))
    
    await client(functions.messages.EditChatAboutRequest(peer=channel,about=about))
    
    update_channel_title(id, title.replace("::", ""), about)

    # Devolver una respuesta de éxito
    return "Canal editado con éxito", 200

@app.route('/delete_channel', methods=['POST'])
async def delete_channel():
    data = await request.get_json()
    phone_number = data['phone_number']
    id = data['id']
    string_session = get_string_session_from_database(phone_number)
    client = TelegramClient(StringSession(string_session), api_id, api_hash)

    await client.connect()

    await client(functions.channels.DeleteChannelRequest(
        channel = int(id)
    ))

    delete_channel_db(int(id))
    # Devolver una respuesta de éxito
    return "Canal eliminado con éxito", 200

if __name__ == '__main__':
    app.run(debug=True)
    # app.run(debug=True, host='0.0.0.0')