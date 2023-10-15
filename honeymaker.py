from faker import Faker
import json
import random
import os
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

fake = Faker()
fake_cn = Faker("zh_CN")
fake_ru = Faker("ru_RU")
fake_es = Faker("es_ES")

# Modify these numbers to alter the script
num_contact_records = 50
faker_obj = fake
contacts_output_file = "contacts.json"
num_paper_dirs = 10
papers_dir = "papers"

contacts = []
for _ in range(num_contact_records):
    uid = "".join(random.choices("ABCDEFGHIJKLMNOPQRSTUVWXYZ", k=8))
    name = faker_obj.name()
    email = faker_obj.email()

    # Choose 3-6 random courses
    all_courses = ["HACS", "CMSC", "MATH", "BMGT", "AMST", "ENES", "BIOE", "STAT", 
                    "BUFN", "CHEM", "PHYS", "HACS", "INST", "MSML", "HESI", "RUSS"]
    courses = random.sample(all_courses, random.randint(3, 6))
    for i in range(len(courses)):
        courses[i] += str(random.randint(6, 8))
        courses[i] += str(random.randint(0, 9))
        courses[i] += str(random.randint(0, 9))

    contact = {"UID": uid, "Name": name, "Email": email, "Courses": courses}

    contacts.append(contact)

# Save the generated data to a JSON file
with open(contacts_output_file, "w") as contacts_file:
    json.dump(contacts, contacts_file, indent=4)

print("Contacts data saved to", contacts_output_file)


def create_folder_structure(papers_dir):
    # Create the main papers directory
    if not os.path.exists(papers_dir):
        os.makedirs(papers_dir)

    # Create numbered subfolders
    for folder_num in range(1, 10):
        folder_path = os.path.join(papers_dir, f"{folder_num}")
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)


create_folder_structure(papers_dir)
for folder_num in range(1, num_paper_dirs):
    papers_folder = os.path.join(papers_dir, f"{folder_num}")
    for paper_num in range(1, random.randint(2, 10)):
        pdf_file = os.path.join(papers_folder, f"paper_{paper_num}.pdf")
        c = canvas.Canvas(pdf_file, pagesize=letter)
        c.setFont("Helvetica", 12)
        x = 20
        y = 750
        line_height = 14

        fake_text = "\n".join(faker_obj.paragraphs(nb=150))

        # Split text into lines and manage placement
        lines = fake_text.split("\n")
        for line in lines:
            c.drawString(x, y, line)
            y -= line_height
        c.save()
    
    for data_num in range(1, random.randint(2,10)):
        data_file = os.path.join(papers_folder, f"research_data_{data_num}.txt")
        
        # Generate fake research results data
        research_results = {
            "Title": faker_obj.sentence(),
            "Author": faker_obj.name(),
            "Abstract": faker_obj.text(max_nb_chars=200),
            "Data": faker_obj.text(max_nb_chars=1000),
        }
        
        # Write the research results to a text file
        with open(data_file, "w") as data:
            data.write(json.dumps(research_results, indent=4))


print("Fake papers and data generated and saved as PDFs.")
