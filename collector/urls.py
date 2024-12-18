from django.urls import path
from collector.views import AccountListView,  CSVUploadView

urlpatterns = [
    path('accounts', AccountListView.as_view(), name='account-list'),
    path('upload-csv', CSVUploadView.as_view(), name='upload-csv'),
]
