# script to change a user's password

import getpass
import subprocess
import sys

ADMIN_DN = "cn=admin,dc=rouge,dc=iut"
BASE_DN = "dc=rouge,dc=iut"
ADMIN_PASS = "admin"

def pwd_hash(pwd):
    return subprocess.check_output(['sudo', 'slappasswd', '-s', pwd]).decode().strip()

def change_user_password():
    uid = input("Entrez l'uid de l'utilisateur dont vous voulez changer le mot de passe: ").strip().lower()
    new_password = getpass.getpass("Entrez le nouveau mot de passe: ")
    new_password_confirm = getpass.getpass("Confirmez le nouveau mot de passe: ")
    
    if new_password != new_password_confirm:
        print("Les mots de passe ne correspondent pas. Le programme va quitter.", file=sys.stderr)
        sys.exit(1)
    
    new_password_hash = pwd_hash(new_password)
    try:
        result = subprocess.run(
            ["ldapsearch", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS, "-b", BASE_DN, f"uid={uid}"],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0 or "dn:" not in result.stdout:
            print(f"Utilisateur {uid} non trouvé.", file=sys.stderr)
            sys.exit(1)
        
        dn_line = next(line for line in result.stdout.split('\n') if line.startswith('dn:'))
        user_dn = dn_line.split('dn: ')[1].strip()
        
        mod_result = subprocess.run(
            ["ldapmodify", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS],
            input=f"dn: {user_dn}\nchangetype: modify\nreplace: userPassword\nuserPassword: {new_password_hash}\n",
            text=True,
            capture_output=True
        )
        
        if mod_result.returncode == 0:
            print(f"Mot de passe de l'utilisateur {uid} changé avec succès.")
        else:
            print(f"Erreur lors du changement de mot de passe: {mod_result.stderr}", file=sys.stderr)
    
    except Exception as e:
        print(f"Erreur lors du changement de mot de passe: {e}", file=sys.stderr)
        
if __name__ == "__main__":
    change_user_password()