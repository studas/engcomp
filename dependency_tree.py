import csv
import json
import os
import sys
from graphviz import Digraph, Graph

def load_data(json_file):
    if not os.path.exists(json_file):
        raise FileNotFoundError(f"The file {json_file} does not exist.")
    
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data

def separate_subjects_by_dependencies(subjects, types: list = ['Obrigatória', 'Optativa Eletiva']):
    dependent = {}
    independent = {}
    for code, subject in subjects.items():
        has_prereq = len(subject.get('requisites', [])) > 0
        is_prereq = len(subject.get('reverse_requisites', [])) > 0
        type = subject.get('type', '')

        if type not in types:
            continue

        if has_prereq or is_prereq:
            dependent[code] = subject
        else:
            independent[code] = subject

    return dependent, independent

def instantiate_painted_node(graph, subjects, code, pos):
    semesters_colors = [
    '#FF0000',  # Red
    '#FFA500',  # Orange
    '#FFFF00',  # Yellow
    '#008000',  # Green
    '#0000FF',  # Blue
    '#4B0082',  # Indigo
    '#EE82EE',  # Violet
    '#FFC0CB',  # Pink
    '#A52A2A',  # Brown
    '#808080',  # Gray
    '#000000'   # Black
    ]
    
    semester = int(subjects[code]['semester'])
    label = f"{code}\n{subjects[code]['name']}"
    pos_str = f"{pos[0]*8},{pos[1]}!"

    if subjects[code]['type'] == 'Obrigatória':
        graph.node(code, label, pos=pos_str, color=semesters_colors[semester], style='filled')
    elif subjects[code]['type'] == 'Optativa Livre':
        graph.node(code, label, pos=pos_str, color=semesters_colors[semester], style='dashed')
    else:
        graph.node(code, label, pos=pos_str, color=semesters_colors[semester])

def process_code(code, dependent_subjects, positions, subjects, semesters):
    """
    Recursively processes a subject code and its reverse requisites.
    
    Args:
        code (str): The subject code to process.
        dependent_subjects (dict): Dictionary of dependent subjects.
        positions (dict): Dictionary to store positions of subjects.
        subjects (dict): Dictionary containing subject details.
        semesters (dict): Dictionary tracking available slots per semester.
    """
    if code in positions:
        return

    # Retrieve the semester for the current code
    semester = int(subjects[code]['semester'])
    semester_pos = semester

    # Assign position and decrement available slots
    positions[code] = (semester_pos, semesters[semester])
    semesters[semester] -= 1

    # Retrieve reverse requisites, if any
    reverse_requisites = subjects[code].get('reverse_requisites', [])
    reverse_requisites.sort(key=lambda x: (int(subjects[x]['semester']), -len(subjects[x].get('reverse_requisites', []))))
    forward_requisites = subjects[code].get('requisites', [])
    forward_requisites.sort(key=lambda x: (int(subjects[x]['semester']), -len(subjects[x].get('requisites', []))))
    requisites = reverse_requisites + forward_requisites

    #remove unwanted type from requisites
    remove_types = ['Optativa Livre', 'Optativa Eletiva']
    removable = []
    for req in requisites:
        if subjects[req]['type'] in remove_types:
            removable.append(req)

    requisites = [req for req in requisites if req not in removable]

    if requisites:
        for req_code in requisites:
            if req_code in positions:
                continue 

            req_semester = int(subjects[req_code]['semester'])

            if req_code in reverse_requisites:
                heights_between = [semesters[i] for i in range(positions[code][0] + 1, req_semester)]
            else: # Forward requisites
                heights_between = [semesters[i] for i in range(req_semester, positions[code][0])]

            should_be_height = semesters[req_semester]
            if heights_between and should_be_height > min(heights_between):
                semesters[req_semester] = min(heights_between)
                
                if req_code in reverse_requisites:
                    for i in range(1, req_semester):
                        semesters[i] = semesters[req_semester] - 1
                    for i in range(req_semester, 11):
                        semesters[i] = semesters[req_semester]
                else: # Forward requisites
                    for i in range(1, req_semester):
                        semesters[i] = semesters[req_semester]
                    for i in range(req_semester, 11):
                        semesters[i] = semesters[req_semester]-1

            process_code(req_code, dependent_subjects, positions, subjects, semesters)

def process_all_codes(dependent_subjects, positions, subjects, semesters):
    """
    Processes a list of subject codes recursively until a subject without requisites is found.
    
    Args:
        dependent_subjects (dict): Dictionary of dependent subjects.
        positions (dict): Dictionary to store positions of subjects.
        subjects (dict): Dictionary containing subject details.
        semesters (dict): Dictionary tracking available slots per semester.
        max_codes (int): Maximum number of codes to process initially.
    """
    codes_to_process = list(dependent_subjects.keys())
    for code in codes_to_process:
        process_code(code, dependent_subjects, positions, subjects, semesters)


if __name__ == "__main__":
    try:
        subjects = load_data('parsed_subjects.json')
    except FileNotFoundError as e:
        print(e)
        sys.exit()

    subs = dict(sorted(subjects.items(), key=lambda x: (x[1]['semester'], -len(x[1].get('reverse_requisites', [])), -len(x[1].get('requisites', [])), x[1]['type'])))

    dependent_subjects, independent_subjects = separate_subjects_by_dependencies(subs, types=['Obrigatória'])

    recursive = Digraph(name='recursive', format='png', engine='neato')
    recursive.attr(overlap='true', esep='10', splines='spline')

    semesters = [0]*11
    positions = {}
    process_all_codes(dependent_subjects, positions, subjects, semesters)

    for code in positions.keys():
        instantiate_painted_node(recursive, subjects, code, positions[code])

    for code in positions.keys():
        requisites = subjects[code].get('reverse_requisites', [])
        if not requisites:
            continue
    
        for req_code in requisites:
            try:
                if positions[code][1] == positions[req_code][1]:
                    recursive.edge(req_code, code)
                else:
                    inv_code = f"inv_{code}_{req_code}"

                    if positions[code][1] < positions[req_code][1]:
                        inv_pos = (positions[req_code][0], positions[code][1])
                    else:
                        inv_pos = (positions[code][0], positions[req_code][1])

                    recursive.node(inv_code, '', pos=f"{inv_pos[0]*8},{inv_pos[1]}!", shape='point', width='0', height='0')
                    recursive.edge(req_code, inv_code, arrowhead='none')
                    recursive.edge(inv_code, code)
            except KeyError:
                continue

    recursive.render('recursive', view=False)