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
        # Already processed this code
        return

    # Retrieve the semester for the current code
    semester = int(subjects[code]['semester'])
    semester_pos = semester

    # Assign position and decrement available slots
    positions[code] = (semester_pos, semesters[semester])
    semesters[semester] -= 1

    # Retrieve reverse requisites, if any
    requisites = subjects[code].get('reverse_requisites', [])
    if requisites:
        # Sort requisites by semester and number of reverse requisites
        requisites.sort(
            key=lambda x: (
                int(subjects[x]['semester']),
                -len(subjects[x].get('reverse_requisites', []))
            )
        )
        for req_code in requisites:
            if req_code in positions:
                continue  # Skip already processed requisites

            # Retrieve semester for the requisite
            req_semester = int(subjects[req_code]['semester'])

            # Calculate available slots between current code's semester and requisite's semester
            heights_between = [
                semesters[i] for i in range(positions[code][0] + 1, req_semester + 1)
            ]

            if heights_between:
                # Assign the minimum available slot to the requisite's semester
                semesters[req_semester] = min(heights_between)
                
                # Update available slots for intervening semesters
                for i in range(1, 11):
                    if i == req_semester:
                        continue
                    semesters[i] = semesters[req_semester] - 1

            # Assign position to the requisite and decrement available slots
            positions[req_code] = (req_semester, semesters[req_semester])
            semesters[req_semester] -= 1

            # Recursively process the requisite
            process_code(req_code, dependent_subjects, positions, subjects, semesters)

def process_all_codes(dependent_subjects, positions, subjects, semesters, max_codes=4):
    """
    Processes a list of subject codes recursively until a subject without requisites is found.
    
    Args:
        dependent_subjects (dict): Dictionary of dependent subjects.
        positions (dict): Dictionary to store positions of subjects.
        subjects (dict): Dictionary containing subject details.
        semesters (dict): Dictionary tracking available slots per semester.
        max_codes (int): Maximum number of codes to process initially.
    """
    codes_to_process = list(dependent_subjects.keys())[:max_codes]
    for code in codes_to_process:
        process_code(code, dependent_subjects, positions, subjects, semesters)


if __name__ == "__main__":
    try:
        subjects = load_data('parsed_subjects.json')
    except FileNotFoundError as e:
        print(e)
        sys.exit()

    subs = dict(sorted(subjects.items(), key=lambda x: (x[1]['semester'], -len(x[1].get('reverse_requisites', [])), -len(x[1].get('requisites', [])), x[1]['type'])))

    dependent_subjects, independent_subjects = separate_subjects_by_dependencies(subs, types=['Obrigatória', 'Optativa Eletiva'])


    positions = {}
    semesters = [0]*11
    for code in list(dependent_subjects.keys())[:4]:
        if code in positions.keys():
            continue

        semester = int(subjects[code]['semester'])
        semester_pos = semester

        positions[code] = (semester_pos, semesters[semester])
        semesters[semester] -= 1

        requisites = subjects[code].get('reverse_requisites', [])
        if requisites:
            #sort requisites by semester and number of reverse_requisites
            requisites.sort(key=lambda x: (int(subjects[x]['semester']), -len(subjects[x].get('reverse_requisites', []))))
            for req_code in requisites:
                if req_code in positions.keys():
                    continue

                
                semester = int(subjects[req_code]['semester'])

                heights_between_code_and_req = []
                for i in range(positions[code][0] + 1, semester+1):
                    heights_between_code_and_req.append(semesters[i])

                semesters[semester] = min(heights_between_code_and_req) if heights_between_code_and_req else semesters[semester]

                if heights_between_code_and_req:
                    semesters[semester] = min(heights_between_code_and_req)
                    for i in range(positions[code][0], semester):
                        semesters[i] = semesters[semester] - 1
                
                positions[req_code] = (semester, semesters[semester])
                semesters[semester] -= 1

    un = Digraph(name='Un', format='png', engine='neato')
    un.attr(overlap='true', esep='10', splines='spline')

    for code in positions.keys():
        instantiate_painted_node(un, subjects, code, positions[code])

    for code in positions.keys():
        requisites = subjects[code].get('reverse_requisites', [])
        if not requisites:
            continue
    
        for req_code in requisites:
            try:
                if positions[code][1] == positions[req_code][1]:
                    un.edge(req_code, code)
                else:
                    inv_code = f"inv_{code}_{req_code}"
                    inv_pos = (positions[code][0], positions[req_code][1])
                    un.node(inv_code, '', pos=f"{inv_pos[0]*8},{inv_pos[1]}!", shape='point', width='0', height='0')
                    un.edge(req_code, inv_code, arrowhead='none')
                    un.edge(inv_code, code)
            except KeyError:
                continue

    recursive = Digraph(name='recursive', format='png', engine='neato')
    recursive.attr(overlap='true', esep='10', splines='spline')

    semesters = [0]*11
    positions = {}
    process_all_codes(dependent_subjects, positions, subjects, semesters, max_codes=10)

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
                    inv_pos = (positions[code][0], positions[req_code][1])
                    recursive.node(inv_code, '', pos=f"{inv_pos[0]*8},{inv_pos[1]}!", shape='point', width='0', height='0')
                    recursive.edge(req_code, inv_code, arrowhead='none')
                    recursive.edge(inv_code, code)
            except KeyError:
                continue

    un.render('un', view=False)
    recursive.render('recursive', view=False)