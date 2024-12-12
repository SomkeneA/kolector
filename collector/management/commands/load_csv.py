import csv
from django.core.management.base import BaseCommand
from collector.models import Agency, Client, Consumer, Account


class Command(BaseCommand):
    help = "Load account data from a CSV file"

    def add_arguments(self, parser):
        parser.add_argument("file_path", type=str, help="Path to the CSV file")

    def handle(self, *args, **kwargs):
        file_path = kwargs["file_path"]

        # Create default agency and client
        agency, _ = Agency.objects.get_or_create(name="Default Agency")
        client, _ = Client.objects.get_or_create(name="Default Client", agency=agency)

        with open(file_path, "r") as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # Create or get account
                account, _ = Account.objects.get_or_create(
                    client=client,
                    balance=row["balance"],
                    status=row["status"],
                )

                # Create or get consumer and link to account
                consumer, _ = Consumer.objects.get_or_create(
                    name=row["consumer name"],
                    address=row["consumer address"],
                    ssn=row["ssn"]
                )
                account.consumers.add(consumer)

        self.stdout.write(self.style.SUCCESS("Data successfully loaded!"))
