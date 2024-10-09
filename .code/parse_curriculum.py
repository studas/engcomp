import json
from bs4 import BeautifulSoup
from collections import defaultdict
import re

def load_html(file_path):
    """
    Load HTML content from a file.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

def parse_subjects(soup):
    """
    Parse subjects from the HTML content.

    Returns:
        subjects_by_code (dict): Dictionary of subjects keyed by their code.
    """
    subjects_by_code = {}
    reverse_requisites = defaultdict(list)

    # Initialize variables to keep track of current section and semester
    current_section = None
    current_semester = None

    # Define the sections to look for
    sections = {
        'Disciplinas Obrigatórias': 'Obrigatória',
        'Disciplinas Optativas Livres': 'Optativa Livre',
        'Disciplinas Optativas Eletivas': 'Optativa Eletiva'
    }

    # Iterate through all table rows
    for row in soup.find_all('tr'):
        # Check for section headers
        header_cell = row.find('td', colspan=True, style=lambda value: value and 'font-weight: bold' in value)
        if header_cell:
            header_text = header_cell.get_text(strip=True)
            if header_text in sections:
                current_section = sections[header_text]
                current_semester = None  # Reset semester when section changes
                continue

            # Check for semester headers within a section
            semester_match = re.match(r'(\d+)[ºo] Semestre Ideal', header_text, re.IGNORECASE)
            if semester_match and current_section:
                current_semester = f"{semester_match.group(1)}"
                continue

        # Check for semester info if it's not in a separate header
        # (Optional: Depending on HTML structure)

        # Check if the row is a subject row
        subject_link = row.find('a', class_='disciplina')
        if subject_link:
            subject_code = subject_link.get_text(strip=True)
            # Assuming the subject name is in the next <td>
            name_cell = row.find_all('td')[1]
            subject_name = name_cell.get_text(strip=True)
            cred_aula = row.find_all('td')[2].get_text(strip=True)
            cred_trab = row.find_all('td')[3].get_text(strip=True)

            # Create the subject entry
            subject = {
                'code': subject_code,
                'name': subject_name,
                'type': current_section,
                'semester': current_semester,
                'cred_aula': cred_aula,
                'cred_trab': cred_trab,
                'requisites': [],
                'reverse_requisites': []
            }

            subjects_by_code[subject_code] = subject
            continue  # Proceed to the next row

        # Check if the row is a requisites row
        # Assuming requisites rows have specific styling, e.g., color
        requisites_cells = row.find_all('td', colspan=True)
        if requisites_cells:
            requisites_text = row.get_text(strip=True)
            if 'Requisito' in requisites_text or 'requisito' in requisites_text:
                # Extract requisite information
                # Assuming requisites are listed in the first two columns separated by " - "
                requisite_info = row.find_all('td')[0].get_text(strip=True)
                if ' - ' in requisite_info:
                    requisite_code = requisite_info.split(' - ', 1)
                    # Assign to the last added subject
                    if subjects_by_code:
                        last_subject = list(subjects_by_code.values())[-1]
                        last_subject['requisites'].append(requisite_code[0])
                        # Build reverse requisites
                        reverse_requisites[requisite_code[0]].append(last_subject['code'])
                continue  # Proceed to the next row

    # After parsing all rows, assign reverse requisites
    for req_code, dependents in reverse_requisites.items():
        if req_code in subjects_by_code:
            subjects_by_code[req_code]['reverse_requisites'] = dependents

    return subjects_by_code

def get_reachable(courses_dict, start_courses, exclude=None):
    """
    Retorna todos os cursos que são alcançáveis a partir dos start_courses.
    Se exclude estiver definido, exclui esse curso da busca.
    """
    visited = set()
    stack = list(start_courses)
    while stack:
        current = stack.pop()
        if current == exclude:
            continue
        if current not in visited:
            visited.add(current)
            if current in courses_dict:
                stack.extend(courses_dict[current]['requisites'])
    return visited

def remove_transitive_requisites(courses_dict):
    """
    Remove pré-requisitos transitivos de cada curso no dicionário
    e atualiza os reverse_requisites correspondentes.
    """
    for course_code, course_info in courses_dict.items():
        direct_reqs = course_info['requisites']
        # Criar uma cópia para evitar modificar a lista enquanto itera
        direct_reqs_copy = direct_reqs.copy()
        for req in direct_reqs_copy:
            # Outros pré-requisitos excluindo o atual
            other_reqs = [r for r in direct_reqs if r != req]
            # Cursos alcançáveis através dos outros pré-requisitos
            reachable = get_reachable(courses_dict, other_reqs)
            if req in reachable:
                print(f"Removendo {req} de {course_code} porque é transitivo.")
                direct_reqs.remove(req)
                # Atualizar reverse_requisites
                if req in courses_dict:
                    reverse_reqs = courses_dict[req].get('reverse_requisites', [])
                    if course_code in reverse_reqs:
                        reverse_reqs.remove(course_code)
                        print(f"Removendo {course_code} de reverse_requisites de {req}.")
    return courses_dict

def main():
    # Path to your HTML file
    html_file = 'grade_curricular.html'

    # Load HTML content
    html_content = load_html(html_file)

    # Parse HTML with BeautifulSoup
    soup = BeautifulSoup(html_content, 'lxml')  # Using 'lxml' parser

    raw_courses = parse_subjects(soup)

    subjects_by_code = remove_transitive_requisites(raw_courses)

    # Optional: Organize subjects by type or semester if needed
    # For example, grouping by type
    curriculum = defaultdict(list)
    for subject in subjects_by_code.values():
        curriculum[subject['type']].append(subject)

    # Save the structured data to a JSON file
    output_file = 'parsed_subjects.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(subjects_by_code, f, ensure_ascii=False, indent=4)

    print(f"Data successfully parsed and saved to {output_file}")

    # Example Access:
    # To access subject details by code:
    # subject = subjects_by_code.get('7600005')
    # print(subject)

if __name__ == "__main__":
    main()
