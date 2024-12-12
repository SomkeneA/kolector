
from django.test import TestCase
from collector.models import Agency, Client, Account, Consumer
from rest_framework.test import APIClient


class AccountAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.agency = Agency.objects.create(name="Test Agency")
        self.client_entity = Client.objects.create(name="Test Client", agency=self.agency)
        self.consumer = Consumer.objects.create(name="John Doe", address="123 Main St", ssn="123-45-6789")
        self.account = Account.objects.create(client=self.client_entity, balance=500, status="in_collection")
        self.account.consumers.add(self.consumer)

    def test_get_all_accounts(self):
        response = self.client.get('/accounts')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_min_balance(self):
        response = self.client.get('/accounts?min_balance=400')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_status(self):
        response = self.client.get('/accounts?status=in_collection')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data['results']), 1)

    def test_filter_by_consumer_name(self):
        response = self.client.get('/accounts?consumer_name=John')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data['results']), 1)
