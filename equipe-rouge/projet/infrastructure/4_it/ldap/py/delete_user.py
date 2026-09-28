# script to delete an existing user

import subprocess
import sys

ADMIN_DN = "cn=admin,dc=rouge,dc=iut"
BASE_DN = "dc=rouge,dc=iut"
ADMIN_PASS = "admin"

def delete_user():
    uid = input("Entrez l'uid de l'utilisateur à supprimer: ")
    
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
        
        del_result = subprocess.run(
            ["ldapdelete", "-x", "-D", ADMIN_DN, "-w", ADMIN_PASS, user_dn],
            capture_output=True,
            text=True
        )
        
        if del_result.returncode == 0:
            print(f"Utilisateur {uid} supprimé avec succès.")
        else:
            print(f"Erreur lors de la suppression de l'utilisateur: {del_result.stderr}", file=sys.stderr)
    
    except Exception as e:
        print(f"Erreur lors de la suppression de l'utilisateur: {e}", file=sys.stderr)

if __name__ == "__main__":
    delete_user()