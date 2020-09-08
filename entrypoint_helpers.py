import sys
import os
import logging
import jinja2 as j2
import re

env = {k: v
    for k, v in os.environ.items()}

jenv = j2.Environment(
    loader=j2.FileSystemLoader('/opt/jinja-templates/'),
    autoescape=j2.select_autoescape(['xml']))

def gen_cfg(tmpl, target):
    print(f"Generating {target} from template {tmpl}")
    cfg = jenv.get_template(tmpl).render(env)
    with open(target, 'w') as fd:
        fd.write(cfg)

def set_props(props, target):
    with open(target, 'r') as f:
        input = f.read()
    tmpInput = input.splitlines()
    output = []
    for k, v in props.items():
        print(f"Setting {k}={v} in {target}")
        key_found = False
        if output:
            tmpInput = output
            output = []
        for line in tmpInput:
            m = re.search(r'^\s*([^=\s]+)\s*=\s*([^=\s]+)?\s*$', line)
            if m and m.group(1) == k:
                key_found = True
                if m.group(2) == v:
                    output.append(line)
                else:
                    output.append(f'{k}={v}')
            else:
                output.append(line)
        if not key_found:
            output.append(f'{k}={v}')
    with open(target,'w') as f:
        f.write('\n'.join(output))