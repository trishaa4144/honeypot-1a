from faker import Faker
import json
import random

fake = Faker()
fake_cn = Faker("zh_CN")
fake_ru = Faker("ru_RU")
fake_es = Faker("es_ES")

# Modify these numbers to alter the script
num_records = 10  # Change this to the desired number of records
faker_obj = fake_es  # Change to the language object you want
all_courses = [
    "HACS", "CMSC", "MATH", "BMGT", "AMST", "ENES", "BIOE","STAT",
    "BUFN", "CHEM", "PHYS", "HACS", "INST", "MSML", "HESI", "RUSS"
]
output_file = "contacts.json"  # Output file for contacts

contacts = []
for _ in range(num_records):
    uid = "".join(random.choices("ABCDEFGHIJKLMNOPQRSTUVWXYZ", k=8))
    name = faker_obj.name()
    email = faker_obj.email()

    # Choose 3-6 random courses
    courses = random.sample(all_courses, random.randint(3, 6))

    for i in range(len(courses)):
        courses[i] += str(random.randint(6,8))
        courses[i] += str(random.randint(0,9))
        courses[i] += str(random.randint(0,9))

    contact = {
        'UID': uid,
        'Name': name,
        'Email': email,
        'Courses': courses
    }
    
    contacts.append(contact)

# Save the generated data to a JSON file
with open(output_file, "w") as contacts_file:
    json.dump(contacts, contacts_file, indent=4)

print("Contacts data saved to", output_file)
