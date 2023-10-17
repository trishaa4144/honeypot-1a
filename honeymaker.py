from faker import Faker
import json
import random
import os
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import argparse


def generate_fake_data(
    num_contact_records: int = 50, num_paper_dirs: int = 10, language: str = None
):
    """
    Generate subdirectory structure containing folders with random amounts of fake research papers,
    data, and contacts in respective language. Saves honey into "generated" folder within the working
    directory.
    """
    faker_obj = None
    papers_dir = "papers"
    contacts_file = "contacts"
    data_filename = "research_data"
    name_label = "Name"
    courses_label = "Courses"
    if language == "russian":
        faker_obj = Faker("ru_RU")
        papers_dir = "документы"
        contacts_file = "контакты"
        name_label = "имя"
        data_filename = "данные"
        courses_label = "Курсы"
    elif language == "spanish":
        faker_obj = Faker("es_ES")
        papers_dir = "documentos"
        contacts_file = "contactos"
        data_filename = "datos"
        name_label = "Nombre"
        courses_label = "Cursos"
    elif language == "chinese":
        faker_obj = Faker("zh_CN")
        papers_dir = "文件"
        contacts_file = "联系人"
        data_filename = "数据"
        name_label = "姓名"
        courses_label = "培训班"
    else:
        faker_obj = Faker()

    create_folder_structure("generated/" + papers_dir)

    generate_contacts(
        faker_obj,
        "generated/" + contacts_file + ".json",
        num_contact_records,
        name_label,
        courses_label,
    )

    # Generate fake papers and data
    for folder_num in range(1, num_paper_dirs):
        papers_folder = os.path.join("generated/" + papers_dir, f"{folder_num}")
        for paper_num in range(1, random.randint(2, 10)):
            pdf_file = os.path.join(papers_folder, f"{papers_dir}_{paper_num}.pdf")
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

        for data_num in range(1, random.randint(2, 10)):
            data_file = os.path.join(papers_folder, f"{data_filename}_{data_num}.txt")

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


def create_folder_structure(papers_dir):
    # Create the main papers directory
    if not os.path.exists(papers_dir):
        os.makedirs(papers_dir)

    # Create numbered subfolders
    for folder_num in range(1, 10):
        folder_path = os.path.join(papers_dir, f"{folder_num}")
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)


def generate_contacts(
    faker_obj, contacts_output_file, num_contact_records, name_label, courses_label
):
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

        contact = {"UID": uid, name_label: name, "Email": email, courses_label: courses}

        contacts.append(contact)

    # Save the generated data to a JSON file
    with open(contacts_output_file, "w") as contacts_file:
        json.dump(contacts, contacts_file, indent=4)

    print("Contacts data saved to", contacts_output_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate contacts & research data.")
    parser.add_argument(
        "--contacts", type=int, default=50, help="Number of contact records to generate"
    )
    parser.add_argument(
        "--papers", type=int, default=10, help="Number of paper directories to create"
    )
    parser.add_argument(
        "--language",
        type=str,
        choices=["english", "spanish", "chinese", "russian"],
        default="english",
        help="Language of honey",
    )
    args = parser.parse_args()

    generate_fake_data(args.contacts, args.papers, args.language)
