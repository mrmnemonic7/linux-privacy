#!/usr/bin/python3
# Written by MrMnemonic7 (C) 2022-2023
# Release under MIT license.
#
# Version 1
# 2022-10-??
# Initial version
#
# Version 2
# 2023-02-20
# - Added exclusions and checksum
# - Half re-written

import os
import sqlite3
import sys
from sqlite3 import Error
from datetime import datetime, timezone
import hashlib

#
#CREATE TABLE IF NOT EXISTS file (
#  id integer PRIMARY KEY AUTOINCREMENT,
#  parent INTEGER NOT NULL,
#  size INTEGER NOT NULL,
#  modified DATETIME NOT NULL,
#  name VARCHAR(255) NOT NULL,
#  checksum VARCHAR(255) NOT NULL,
#  data BLOB NOT NULL
#);
#
#CREATE TABLE IF NOT EXISTS folder (
#  id integer PRIMARY KEY AUTOINCREMENT,
#  parent INTEGER NOT NULL,
#  name VARCHAR(255) NOT NULL,
#);

def getmd5hash(filename):
    with open(filename, "rb") as f:
        file_hash=hashlib.md5()
        while chunk := f.read(8192):
            file_hash.update(chunk)
    f.close()
    return file_hash.hexdigest()

def insert_into_database(file_name, file_size, file_date, file_checksum):
    modified = datetime.fromtimestamp(file_date)
    print("Processing "+file_name+" Size: "+file_size+" Date: "+modified)
    with open(file_name, "rb") as file:
        data = file.read()

        try:
            cur = conn.cursor()
            sql_insert_file_query = '''INSERT INTO file (parent, size, modified, name, checksum, data)
                VALUES(?, ?, ?, ?, ?, ?)'''
            cur = conn.cursor()
            cur.execute(sql_insert_file_query, (0, file_size, modified, file_name, file_checksum, data))
            conn.commit()
            print("[INFO] : The blob for ", file_name, " is in the database.") 
            last_updated_entry = cur.lastrowid
            return last_updated_entry
        except Error as e:
            print("Error: ",e)
        file.close()

def write_data_to_file(file_name, data):
    with open(file_name, "wb") as f:
        f.write(data)
    f.close()
#    print("[INFO] Wrote file "+file_name)

def db_export_files(databasefile):
    file_num=0
    current_path = './'
    cur = conn.cursor()
    sql_fetch_files = """SELECT * FROM file"""
    cur.execute(sql_fetch_files)
    record = cur.fetchall()
    for row in record:
        file_name = row[4]
        file_checksum = row[5]
        file_data = row[6]
        print("[INFO] Writing "+file_name, end=" ")
        path_to_file=current_path+file_name
        write_data_to_file(path_to_file, file_data)
        if getmd5hash(file_name) == file_checksum:
            print("= Checksum Confirmed")
        else:
            print("= [ERROR] Checksum Error")
        file_num=file_num+1
    print(file_num," processed.")

def db_import_files(databasefile):
    file_num=0
    path_of_the_directory = './'
    #for data_file in os.listdir(path_of_the_directory):
    for data_file in os.scandir(path_of_the_directory):
        path = os.path.join(path_of_the_directory, data_file)
        # skip directories
        if os.path.isdir(path):
            continue
        # don't include our own database
        if data_file.name == databasefile:
            continue
        # don't include us either
        if data_file.name == os.path.basename(__file__):
            continue
        # get checksum
        checksum=getmd5hash(data_file.name)
        # do we already have it?
        cur = conn.cursor()
        cur.execute("""SELECT name,checksum
                   FROM file
                   WHERE name=?
                       AND checksum=?""",
                (data_file.name, checksum))
        result = cur.fetchone()
        if result:
            print("Already have "+data_file.name)
            continue
#        print("DEBUG: Importing "+data_file.name+", size: "+str(data_file.stat().st_size)+", time: "+str(data_file.stat().st_mtime)+", checksum: "+checksum)
        insert_into_database(data_file.name, data_file.stat().st_size, data_file.stat().st_mtime, checksum)
        file_num=file_num+1
    print(file_num," processed.")

if __name__ == "__main__":
    global conn
    print("File2DB v2 by MrMnemonic7.")
    cmd=sys.argv[1]
    databasefile=sys.argv[2]
    conn = sqlite3.connect(databasefile)
    print("[INFO] Successful connection!")
    if cmd == "import":
        print("[INFO] Importing into "+databasefile)
        db_import_files(databasefile)
    if cmd == "export":
        print("[INFO] Exporting from "+databasefile)
        db_export_files(databasefile)
    conn.close()
    print("[INFO] Successful close!")
