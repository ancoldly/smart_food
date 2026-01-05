from django.urls import path

from .views import InteractionIngestView, RecommendationFeedView, SimilarProductsView

urlpatterns = [
    path("events/", InteractionIngestView.as_view(), name="recommendation-events"),
    path("feed/", RecommendationFeedView.as_view(), name="recommendation-feed"),
    path("similar/", SimilarProductsView.as_view(), name="recommendation-similar"),
]
