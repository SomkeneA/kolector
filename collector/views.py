from django.shortcuts import render

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.pagination import PageNumberPagination
from collector.models import Account
from collector.serializers import AccountSerializer
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
import csv
from io import TextIOWrapper
from collector.models import Agency, Client, Consumer, Account


class AccountListView(APIView):
    def get(self, request):
        # Fetch all accounts
        accounts = Account.objects.all()

        # Apply filters
        min_balance = request.query_params.get('min_balance')
        max_balance = request.query_params.get('max_balance')
        consumer_name = request.query_params.get('consumer_name')
        status_param = request.query_params.get('status')

        if min_balance:
            accounts = accounts.filter(balance__gte=min_balance)
        if max_balance:
            accounts = accounts.filter(balance__lte=max_balance)
        if consumer_name:
            accounts = accounts.filter(consumers__name__icontains=consumer_name)
        if status_param:
            accounts = accounts.filter(status=status_param)

        # Apply pagination
        paginator = PageNumberPagination()
        paginator.page_size = 10
        paginated_accounts = paginator.paginate_queryset(accounts, request)

        # Serialize and return the paginated results
        serializer = AccountSerializer(paginated_accounts, many=True)
        return paginator.get_paginated_response(serializer.data)

class CSVUploadView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        file_obj = request.FILES.get('file', None)

        if not file_obj:
            return Response({"error": "No file provided."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Parse the uploaded CSV file
            file_wrapper = TextIOWrapper(file_obj.file, encoding='utf-8')
            reader = csv.DictReader(file_wrapper)

            # Create default agency and client
            agency, _ = Agency.objects.get_or_create(name="Default Agency")
            client, _ = Client.objects.get_or_create(name="Default Client", agency=agency)

            for row in reader:
                # Create or get account
                account, _ = Account.objects.get_or_create(
                    client=client,
                    balance=row['balance'],
                    status=row['status'],
                )

                # Create or get consumer and link to account
                consumer, _ = Consumer.objects.get_or_create(
                    name=row['consumer name'],
                    address=row['consumer address'],
                    ssn=row['ssn']
                )
                account.consumers.add(consumer)

            return Response({"message": "CSV file processed successfully."}, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)