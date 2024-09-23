{
  "sourceType": ["S3"],
  "sourceInfo": ["{\"path\":\"https://s3.amazonaws.com/your-bucket-name/path/to/your-playbook.yml\"}"],
  "playbookFile": ["your-playbook.yml"],
  "extraVariables": ["SSM=True"],
  "check": ["False"],
  "timeoutSeconds": ["3600"]
}


aws ssm send-command \
    --document-name "AWS-ApplyAnsiblePlaybooks" \
    --instance-ids "i-1234567890abcdef0" \
    --parameters file://params.json \
    --output-s3-bucket-name "your-output-bucket-name" \
    --output-s3-key-prefix "ansible-outputs/"

---
- name: Hello World Playbook
  hosts: localhost
  gather_facts: no

  tasks:
    - name: Print hello world
      debug:
        msg: "Hello World from Ansible!"

    - name: Create a file with hello world message
      copy:
        content: "Hello World from Ansible!\nPlaybook executed at {{ ansible_date_time.iso8601 }}"
        dest: "/tmp/hello_world.txt"

    - name: Read the content of the file
      command: cat /tmp/hello_world.txt
      register: file_content

    - name: Display file content
      debug:
        var: file_content.stdout_lines