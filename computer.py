#!/usr/bin/env python3

import os
import platform
import openai
import sys
import subprocess
import dotenv 
import distro
import yaml
import pyperclip
import keyring

#import loggin

from termcolor import colored
from colorama import init



def read_config() -> any:

  ## Find the executing directory (e.g. in case an alias is set)
  ## So we can find the config file
  computer_path = os.path.abspath(__file__)
  prompt_path = os.path.dirname(computer_path)

  root_file = os.path.join(prompt_path, "root.yaml")
  with open(root_file, 'r') as file:
    global root_data
    root_data = yaml.safe_load(file)

  config_file = os.path.join(prompt_path, "computer.yaml")
  with open(config_file, 'r') as file:
    return yaml.safe_load(file)
  
  
# Construct the prompt
def get_full_prompt(user_prompt, shell):
  ## Find the executing directory (e.g. in case an alias is set)
  ## So we can find the prompt.txt file
  computer_path = os.path.abspath(__file__)
  prompt_path = os.path.dirname(computer_path)

  ## Load the prompt and prep it
  prompt_file = os.path.join(prompt_path, "prompt.txt")
  pre_prompt = open(prompt_file,"r").read()
  pre_prompt = pre_prompt.replace("{shell}", shell)
  pre_prompt = pre_prompt.replace("{os}", get_os_friendly_name())
  prompt = pre_prompt + user_prompt

  #loggin.log_chat_info(user_prompt, "res_command")
  
  # be nice and make it a question
  if prompt[-1:] != "?" and prompt[-1:] != ".":
    prompt+="?"

  return prompt

#Get the prompt asked
def get_prompt(user_prompt):

  prompt = user_prompt
  if prompt[-1:] != "?" and prompt[-1:] != ".":
    prompt+="?"

  user_pr = prompt
  return user_pr



def print_usage():
  file = f'{os.getcwd()}/computer.py'

  print(colored("Combot Computer Version: 2.0.0", "blue"))
  print(colored("Os information :"))
  print(""" 
        - Name: Posix
        - Python version: %s
        - System: %s
        - Machine: %s
        - Platform: %s
        - Uname: %s
        - Version: %s
        - Mac_ver: %s
      """ % (
      sys.version.split('\n'),
      platform.system(),
      platform.machine(),
      platform.platform(),
      platform.uname(),
      platform.version(),
      platform.mac_ver(),
      ))

  print(colored("Current configuration per computer.yaml:","blue"))
  print(colored("* Model        : ", "green") + str(config["model"]))
  print(colored("* Temperature  : ", "green") + str(config["temperature"]))
  print(colored("* Max. Tokens  : ", "green") + str(config["max_tokens"]))
  print(colored("* Safety       : ", "green") + str(bool(config["safety"])))
  print()
  print(colored("Directory Information:","blue"))
  print(colored(f"* Path        : {file}", "green"))
  print(colored("Set Up Comands:","blue"))
  print(colored("* Api        : ", "green") + "computer --API : API_KEY")
  print(colored("* Gpt Model        : ", "green") + "computer --MODEL : model (eg. gpt-3.5-turbo)")
  print(colored("* Root Mode       : ", "green") + "computer --PSW : ROOT_PASS (eg. 1234)(Optional)")
  print(colored("* Default Root Mode      : ", "green") + "computer --PSW : nopass (Set to 'nopass')")
  print(colored("Command:","blue"))
  print(colored("* Generative Prompt        : ", "green") + "computer -c YOUR_PROMPT")
  print(colored("* Terminal Functions       : ", "green") + "computer YOUR_PROMPT")
  print(colored("* Information      : ", "green") + "computer -i")
  print(colored("* Issues      : ", "green") + "https://github.com/blueraymusic/Cmd-bot")


  #print(colored(f"* Size        : {os.path.getsize(file)}", "green"))
  print()



def get_os_friendly_name():
  # Get OS Name
  os_name = platform.system()
  
  if os_name == "Linux":
    return "Linux/"+distro.name(pretty=True)
  elif os_name == "Windows":
    return os_name
  elif os_name == "Darwin":
    return "Darwin/macOS"
  else:
    return os_name


def set_api_key():
  dotenv.load_dotenv()
  openai.api_key = config["openai_api_key"]
  
  # Place a ".openai.apikey" in the home directory that holds the line:
  #   <yourkey>

  if not openai.api_key:  #If statement to avoid "invalid filepath" error
    home_path = os.path.expanduser("~")    
    openai.api_key_path = os.path.join(home_path,".openai.apikey")

  #the key might be in the computer.yaml config file
  if not openai.api_key:  
    openai.api_key = config["openai_api_key"]

  #if all the previous statements turn out false
  if not openai.api_key:
    print(colored("The API key couldn't be proccessed 😞: \n   Place a '.openai.apikey' in the home directory that holds the line:    \n     <yourkey> \n   Or Place your key in the computer.yaml file \n   Or Place your key in the file computer.py in the variable 'openai.api_key' ", "red"))

def replace_multiple(text, replace_dict):
    for old_value, new_value in replace_dict.items():
        text = text.replace(old_value, new_value)
    return text
    
def api(query):
  computer_path = os.path.abspath(__file__)
  prompt_path = os.path.dirname(computer_path)
  computeryaml = os.path.join(prompt_path, "computer.yaml")
  computeroot = os.path.join(prompt_path, "root.yaml")
  
  if not os.path.exists(computeryaml):
    sys.exit(f"Issue encountered:\n   Re-install the package  or Create a new computer.yaml file in the following directory: {prompt_path}\n   If creating a new computer.yaml file, it has to contain the following variables:\n     model: gpt-3.5-turbo (Changeable version based on the API)\n     temperature: 0 (for precision)\n     max_tokens: 500\n     safety: False/True (Choose your safety mode)\n     openai_api_key: YOUR_API_KEY\n ")

  if not os.path.exists(computeroot):
    sys.exit(f"Issue encountered:\n   Re-install the package  or Create a new root.yaml file in the following directory: {prompt_path}\n   If creating a new root.yaml file, it has to contain the following variable:\n     pass: ROOT_PASS or 'nopass' for default setup\n ")

  if "--API" in query:
      replace_dict = {"--API": "", " ": "", '"': '', "'":""}
      prompt = replace_multiple(str(query), replace_dict)

      def set_state(state):
        with open(computeryaml) as f:
            doc = yaml.safe_load(f)
        doc['openai_api_key'] = state
        with open(computeryaml, 'w') as f:
            yaml.dump(doc, f)

      openai.api_key = str(prompt)

      if openai.api_key:
        try:
            # Make a test request to check if the API key is valid
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "user", "content": "hi"}
                ],
                temperature=0.7, 
                max_tokens=10, 
            )
            print(colored("Success:", "green"), "API key is valid.")
            print(colored("* Api        : ", "green") + str(prompt))
            set_state(prompt)
            sys.exit(0)
        except openai.error.OpenAIError as e:
            print(colored("Error:", "red"), "Invalid API key")
            print(colored("* Api        : ", "red") + str(prompt))
            print(colored("* Error message: ", "red") + str(e))
            sys.exit(1)  
      else:
          set_state(prompt)
          sys.exit("API: Empty \n")


  elif "--MODEL" in query:
      replace_dict = {"--MODEL": "", " ": "", '"': '', "'":""}
      prompt = replace_multiple(str(query), replace_dict)
      
      def set_state(state):
        with open(computeryaml) as f:
            doc = yaml.safe_load(f)
        doc['model'] = state
        with open(computeryaml, 'w') as f:
            yaml.dump(doc, f)

      if openai.api_key:
        try:
            # Make a test request to check if the API key is valid
            response = openai.ChatCompletion.create(
                model=str(prompt),
                messages=[
                    {"role": "user", "content": "hi"}
                ],
                temperature=0.7, 
                max_tokens=10, 
            )
            print(colored("Success:", "green"), "Model key is valid.")
            print(colored("* Model        : ", "green") + str(prompt))
            set_state(prompt)
            sys.exit(0)
        except openai.error.OpenAIError as e:
            print(colored("Error:", "red"), "Invalid Model key")
            print(colored("* Model        : ", "red") + str(prompt))
            print(colored("* Error message: ", "red") + str(e))
            sys.exit(1)  
      else:
          sys.exit("API: Please set the API \n")

  elif "--PSW" in query:
      replace_dict = {"--PSW": "", " ": "", '"': '', "'":""}
      prompt = replace_multiple(str(query), replace_dict)
      computerpass = os.path.join(prompt_path, "root.yaml")
      
      def set_state(state):
        with open(computerpass) as f:
            doc = yaml.safe_load(f)
        doc['pass'] = state
        with open(computerpass, 'w') as f:
            yaml.dump(doc, f)

      set_state(prompt)
      print(colored("Success:", "green"), "Passkey key set.")
    


if __name__ == "__main__":
  print("")

  # Unix based SHELL (/bin/bash, /bin/zsh), otherwise assuming it's Windows
  shell = os.environ.get("SHELL", "powershell.exe") 

  command_start_idx  = 1     # Question starts at which argv index?
  ask_flag = False           # safety switch -a command line argument
  gpt = False
  info = False
  computer = ""                  # user's answer to safety switch (-a) question y/n

  # Parse arguments and make sure we have at least a single word
  if len(sys.argv) < 2:
    print_usage()
    sys.exit(-1)

  # Safety switch via argument -a (local override of global setting)
  # Force Y/n questions before running the command
  if sys.argv[1] == "-a":
    ask_flag = True
    command_start_idx = 2
  
  elif sys.argv[1] == "-c":
    gpt = True
    command_start_idx = 2

  elif sys.argv[1] == "-i":
    info = True
    command_start_idx = 2

  
  arguments = sys.argv[command_start_idx:]
  user_prompt = " ".join(arguments)

  api(user_prompt)
  config = read_config()
  set_api_key()



def call_open_ai(query):

  # do we have a prompt from the user?
  if query == "" and info == False:
      print ("No user prompt specified.")
      sys.exit(-1)

  api(query)

  if info:
    return ""
 
  # Load the correct prompt based on Shell and OS and append the user's prompt
  prompt = get_full_prompt(query, shell)

  #make it global
  global user
  user = str(get_prompt(query))

  # Make the first line also the system prompt
  system_prompt = prompt[1]
  #print(prompt)

  # Call the ChatGPT API
  response = openai.ChatCompletion.create(
    model=config["model"],
    messages=[
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt}
    ],
    temperature=config["temperature"],
    max_tokens=config["max_tokens"],
  )
 
  return response.choices[0].message.content.strip()


#Enable color output on Windows using colorama
init() 

def check_for_issue(response):
  prefixes = ("sorry", "i'm sorry", "the question is not clear", "i'm", "i am")
  if response.lower().startswith(prefixes):
    print(colored(response+" 😞", 'red'))
    sys.exit(-1)

def check_for_markdown(response):
  # odd corner case, sometimes ChatCompletion returns markdown
  if response.count("```",2):
    print(colored("The proposed command contains markdown, so I did not execute the response directly 😞 : \n", 'red')+response)
    sys.exit(-1)

def missing_posix_display():
  display = subprocess.check_output("echo $DISPLAY", shell=True)
  return display == b'\n'

def prompt_user_input(response):
  print("Command: " + colored(response, 'blue'))
  #print(config["safety"])

  remove = False
  delete = ("rm", "delete", "remove", "reboot", "shutdown", "passwd", "chown", "adduser", "sudo systemctl reboot", "restart", "sudo reboot", "sudo shutdown -r", "sudo launchctl reboot", "sudo init 6")
  res_m = response.lower()
  if res_m.startswith(delete):
    remove = True
  

  if bool(config["safety"]) == True or ask_flag == True or remove == True:
    prompt_text = "Execute command? [Y]es [n]o [m]odify [c]opy to clipboard ==> "
    if os.name == "posix" and missing_posix_display():
        prompt_text =  "Execute command? [Y]es [n]o [m]odify ==> "
    print(prompt_text, end = '')
    user_input = input()
    remove = False
    return user_input 
  
  if config["safety"] == False or remove == False:
     return "Y"





def evaluate_input(user_input, command):
  arguments = sys.argv[2:]
  user_prompt = " ".join(arguments)
  if gpt:
      messages = [ {"role": "system", "content":  
              "You are a intelligent assistant."} ] 
      message = user_prompt

      if message: 
          messages.append( 
              {"role": "user", "content": message}, 
          ) 
          chat = openai.ChatCompletion.create( 
              model="gpt-3.5-turbo", messages=messages 
          ) 
      reply = chat.choices[0].message.content 

      if message.lower() == "hi":
        reply = """
          .------.
          |  Hi  |
          '------'
              ^      (\_/)
              '----- (O.o)
                     (> <)
                     _/ \_
          """
        print(colored(str(reply)+"\n",'blue'))
      
      elif "fishack" in message.lower():
        computer_path = os.path.abspath(__file__)
        prompt_path = os.path.dirname(computer_path)
        middlesh = os.path.join(prompt_path, "middle.sh")
        com = f"bash {middlesh}"
        
        try:
          subprocess.run([shell, "-c", str(com)], shell=False)
          command = ""
        except subprocess.CalledProcessError as e:
          print(f"Error: {e}")

      
      else:
        #messages.append({"role": "assistant", "content": reply})
        print("Generated Response: " + colored(str(reply)+"\n",'blue'))
        command = ""
        user_prompt = "none"


  if info:
    print_usage()
    print("$-------------------------------$")
    user_prompt= "none"


  if user_input.upper() == "Y" or user_input == "":
      if root_data["pass"] != "nopass":
        command = f'echo {root_data["pass"]} | sudo -S {command}'
        
      if shell == "powershell.exe":
        try:
          subprocess.run([shell, "/c", command], shell=False)
        except:
          sys.exit("Error: Command invalid or Root command invalid !")  
      else: 
        # Unix: /bin/bash /bin/zsh: uses -c both Ubuntu and macOS should work, others might not
        try:
          subprocess.run([shell, "-c", command], shell=False)
        except:
          sys.exit("Error: Command invalid or Root command invalid !")  
    
  if user_input.upper() == "M":
    print("Modify prompt: ", end = '')
    modded_query = input()
    modded_response = call_open_ai(modded_query)
    check_for_issue(modded_response)
    check_for_markdown(modded_response)
    modded_user_input = prompt_user_input(modded_response)
    print()
    evaluate_input(modded_user_input, modded_response)
  
  if user_input.upper() == "C":
      if os.name == "posix" and missing_posix_display():
        return
      pyperclip.copy(command) 
      print("Copied command to clipboard.")

  

try: 
  res_command = call_open_ai(user_prompt) 
except:
  sys.exit(colored("The API key couldn't be proccessed 😞: \n   Place a '.openai.apikey' in the home directory that holds the line:    \n     <yourkey> \n   Or Place your key in the computer.yaml file \n   Or Place your key in the file computer.py in the variable 'openai.api_key'\n   Or Enter: computer --API: YOUR_API_KEY\n   Or Type (for more information): Computer -i\n   ", "red"))

check_for_issue(res_command)
check_for_markdown(res_command)
user_input = prompt_user_input(res_command)
print()
evaluate_input(user_input, res_command)
print("")

#test with default set data
osname = platform.system()
architecture = platform.architecture()
release = platform.release()


#loggin.log_chat_info(user,str(res_command), osname, architecture, release)