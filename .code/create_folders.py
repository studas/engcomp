import json
import os
import sys

def load_data(json_file):
    if not os.path.exists(json_file):
        raise FileNotFoundError(f"The file {json_file} does not exist.")
    
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data

if __name__ == "__main__":
    try:
        subjects = load_data('.code/parsed_subjects.json')
    except FileNotFoundError as e:
        print(e)
        sys.exit()

    folders = []

    for subject in subjects.values():
        name = subject['name']
        code = subject['code']
        semester = subject['semester']
        tipo = subject['type']
        cred_aula = subject['cred_aula']
        cred_trab = subject['cred_trab']
        string = f"{name} - {code}"
    
        if tipo == 'Obrigatória':
            path = string
        elif tipo == 'Optativa Eletiva':
            path = f"01. Eletivas/{string}"
        elif tipo == 'Optativa Livre':
            path = f"02. Livres/{string}"

        os.makedirs(path, exist_ok=True)

        #create a file with the subject description
        with open(f"{path}/info.md", 'w', encoding='utf-8') as file:
            file.write(f"# {code} - {name}\n{tipo} - {semester}º Período\n{cred_aula} créditos aula e {cred_trab} créditos trabalho\n")


