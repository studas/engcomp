import csv
import json
import os
import sys
from graphviz import Digraph, Graph

def load_data(json_file):
    """
    Load JSON data from a file.

    Args:
        json_file (str): Path to the JSON file.

    Returns:
        dict: Parsed JSON data.
    """
    if not os.path.exists(json_file):
        raise FileNotFoundError(f"The file {json_file} does not exist.")
    
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data

def separate_subjects_by_dependencies(subjects, types: list = ['Obrigatória', 'Optativa Eletiva']):
    """
    Filter subjects to include only those with dependencies.

    Args:
        subjects (dict): Dictionary of subjects keyed by their code.

    Returns:
        dict: Filtered subjects dictionary.
    """
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
    pos_str = f"{pos[0]},{pos[1]}!"

    if subjects[code]['type'] == 'Obrigatória':
        graph.node(code, label, pos=pos_str, color=semesters_colors[semester], style='filled')
    elif subjects[code]['type'] == 'Optativa Livre':
        graph.node(code, label, pos=pos_str, color=semesters_colors[semester], style='dashed')
    else:
        graph.node(code, label, pos=pos_str, color=semesters_colors[semester])

def add_node(g, subjects, code, y_pos, positions):
    """
    Add a node to the graph.

    Args:
        g (Graph): Graph object.
        subjects (dict): Dictionary of subjects keyed by their code.
        code (str): Subject code.
        y_pos (float): Y position for the node.
        visited (set): Set of visited subject codes.
    """
    if code in positions.keys():
        return y_pos

    requisites = subjects[code].get('requisites', [])
    semester = int(subjects[code]['semester'])
    x_pos = semester*8

    y_final_pos = y_pos

    if requisites:
        heights = []
        for req_code in requisites:
            if req_code in positions.keys():
                heights.append(positions[req_code][1])
        
        if heights:
            heights.sort()
            y_final_pos = max(heights) - 1

            nodes_in_semester = [node for node, pos in positions.items() if pos[0] == x_pos]
            if nodes_in_semester:
                nodes_in_semester.sort()
                #get biggest in hights that is smaller than the smallest in nodes_in_semester
                y_final_pos = max([height for height in heights if height < positions[nodes_in_semester[0]][1]] + [y_pos]) - 1

    if y_final_pos != y_pos:
        #update all the nodes at the lower y_pos to go down by one
        for node, pos in positions.items():
            if pos[1] <= y_final_pos:
                positions[node] = (pos[0], pos[1] - 1)
                
    positions[code] = (x_pos, y_final_pos)

    print(f"Adding {subjects[code]['name']} at {(semester, y_pos)}")
    instantiate_painted_node(g, subjects, code, positions[code])

    if not requisites:
        return y_pos - 1
    
    for next_code in requisites:
        y_pos = add_node(g, subjects, next_code, y_pos, positions)

        if positions[code][1] == positions[next_code][1]:
            g.edge(code, next_code)
        else: 
            inv_code = f"inv_{code}_{next_code}"

            if positions[code][1] > positions[next_code][1]:
                positions[inv_code] = (positions[code][0], positions[next_code][1])
            else:
                positions[inv_code] = (positions[next_code][0], positions[code][1])

            g.node(inv_code, "", pos=f"{positions[inv_code][0]},{positions[inv_code][1]}!", shape='point', width='0', height='0')

            g.edge(code, inv_code, arrowhead='none')
            g.edge(inv_code, next_code)

    return y_pos - 0.5


if __name__ == "__main__":
    try:
        subjects = load_data('parsed_subjects.json')
    except FileNotFoundError as e:
        print(e)
        sys.exit()

    subs = dict(sorted(subjects.items(), key=lambda x: (-len(x[1].get('requisites', [])), x[1]['type'], x[1]['semester'], -len(x[1].get('reverse_requisites', [])))))

    dependent_subjects, independent_subjects = separate_subjects_by_dependencies(subs, types=['Obrigatória', 'Optativa Eletiva'])

    g = Digraph(name='AbsolutePositionGraph', engine='neato', format='png')
    g.attr(overlap='true', esep='10', splines='spline')

    visited = {}

    '''
    semesters = [0]*11
    for code in independent_subjects.keys():
        semester = int(subjects[code]['semester'])
        semester_pos = semester*8
        semesters[semester] -= 1

        instantiate_painted_node(subjects, code, (semester_pos, semesters[semester]))
    '''

    y_pos = 0 #min(semesters) - 
    # only the first 10 subjects are added to the graph
    new_list = list(dependent_subjects.keys())[:4]
    for subject_code in new_list:
        y_pos = add_node(g, subjects, subject_code, y_pos, visited)
    
    output_path = g.render('absolute_position_graph', view=False)

    un = Digraph(name='Un', format='png', engine='neato')
    un.attr(overlap='true', esep='10', splines='spline')

    print (visited)
    for code in visited.keys():
        print(code)
        if 'inv_' in code:
            continue
        print(f"Adding {subjects[code]['name']} at {visited[code]}")
        instantiate_painted_node(un, subjects, code, visited[code])

    un.render('un', view=False)