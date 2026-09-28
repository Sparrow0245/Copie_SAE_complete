# script to create a new user

import getpass
import subprocess
import sys
import re

ADMIN_DN = "cn=admin,dc=rouge,dc=iut"
BASE_DN = "dc=rouge,dc=iut"
ADMIN_PASS = "admin"

def pwd_hash(pwd):
    return subprocess.check_output(['sudo', 'slappasswd', '-s', pwd]).decode().strip()

def uid_gen(prenom, nom):
    uid = (prenom[0] + nom).lower()
    
    try:
        result = subprocess.run(
            ["ldapsearch", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS, "-b", BASE_DN, f"uid={uid}"],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0 and "dn:" in result.stdout:
            counter = 1
            while True:
                new_uid = f"{uid}{counter}"
                result = subprocess.run(
                    ["ldapsearch", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS, "-b", BASE_DN, f"uid={new_uid}"],
                    capture_output=True,
                    text=True
                )
                if result.returncode != 0 or "dn:" not in result.stdout:
                    uid = new_uid
                    break
                counter += 1
    except Exception as e:
        print(f"Erreur lors de la vérification de l'uid: {e}", file=sys.stderr)
    
    return uid

def get_next_uid_gid_number():
    try:
        result = subprocess.run(
            ["ldapsearch", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS, "-b", BASE_DN, "uidNumber"],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print(f"Erreur lors de la requête LDAP: {result.stderr}", file=sys.stderr)
            return 10000, 10000 # fallback
        
        uid_numbers = []
        for line in result.stdout.split('\n'):
            if line.startswith('uidNumber:'):
                match = re.search(r'uidNumber:\s*(\d+)', line)
                if match:
                    uid_numbers.append(int(match.group(1)))
        
        if uid_numbers:
            next_number = max(uid_numbers) + 1
        else:
            next_number = 10000 # first uid/gid
        
        return next_number, next_number
    
    except Exception as e:
        print(f"Erreur lors de la recherche du prochain uid/gid: {e}", file=sys.stderr)
        return 10000, 10000 # fallback to default
    
def create_user():
    prenom = input("Prénom de l'utilisateur: ").strip()
    nom = input("Nom de l'utilisateur: ").strip()
    uid = uid_gen(prenom, nom)
    email = f"{uid}@rouge.iut"
    
    if not all([prenom, nom, uid, email]):
        print("Tous les champs sont obligatoires. Le programme va quitter.")
        sys.exit(1)

    user_pass = getpass.getpass("Mot de passe de l'utilisateur: ").strip()
    if not user_pass:
        print("Le mot de passe ne peut pas être vide. Le programme va quitter.")
        sys.exit(1)
    
    hashed_pwd = pwd_hash(user_pass)
    user_dn = f"uid={uid},ou=users,{BASE_DN}"
    uid_number, gid_number = get_next_uid_gid_number()
    
    ldif_content = f"""dn: {user_dn}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: {uid}
cn: {prenom} {nom}
sn: {nom}
givenName: {prenom}
mail: {email}
userPassword: {hashed_pwd}
uidNumber: {uid_number}
gidNumber: {gid_number}
homeDirectory: /home/{uid}
loginShell: /bin/bash
"""

    with open("/tmp/new_user.ldif", "w") as f:
        f.write(ldif_content)
    
    try:
        result = subprocess.run(
            ["ldapadd", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS, "-f", "/tmp/new_user.ldif"],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(f"Utilisateur {uid} ajouté avec succès.")
            print(f"DN: {user_dn}")
        else:
            print(f"Erreur lors de l'ajout de l'utilisateur: {result.stderr}", file=sys.stderr)
            sys.exit(1)
    
    finally:
        subprocess.run(["rm", "-f", "/tmp/new_user.ldif"])
        
if __name__ == "__main__":
    create_user()
    