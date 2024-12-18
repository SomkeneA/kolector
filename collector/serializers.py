from rest_framework import serializers
from collector.models import Account


class AccountSerializer(serializers.ModelSerializer):
    consumers = serializers.StringRelatedField(many=True)  # Show consumer names in the response
    client = serializers.StringRelatedField()  # Show client name in the response

    class Meta:
        model = Account
        fields = ['id', 'client', 'balance', 'status', 'consumers']
