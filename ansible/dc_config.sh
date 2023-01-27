bash -c 'source ../ansible/venv/bin/activate && ansible-playbook ../ansible/domain-controllers.yml --tags=common,base -v'
bash -c 'source ../ansible/venv/bin/activate && ansible-playbook ../ansible/domain-controllers.yml --tags=common,init -v'

