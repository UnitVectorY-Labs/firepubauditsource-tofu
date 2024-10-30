# Enable required APIs for Cloud Run, Eventarc, Pub/Sub, and Firestore
resource "google_project_service" "run" {
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "eventarc" {
  project            = var.project_id
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "pubsub" {
  project            = var.project_id
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore" {
  project            = var.project_id
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

# Create Pub/Sub topic messages are published to
resource "google_pubsub_topic" "firepubauditsource_topic" {
  project                    = var.project_id
  name                       = "fpas-${var.name}"
  message_retention_duration = "86600s"
}

# Service account for Cloud Run services
resource "google_service_account" "cloud_run_sa" {
  project      = var.project_id
  account_id   = "fpas-${var.name}"
  display_name = "firepubauditsource Cloud Run (${var.name}) service account"
}

# IAM role to grant Pub/Sub publish permissions to Cloud Run service account
resource "google_pubsub_topic_iam_member" "pubsub_publisher_role" {
  project = var.project_id
  topic   = google_pubsub_topic.firepubauditsource_topic.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

locals {
  final_artifact_registry_project_id = coalesce(var.artifact_registry_project_id, var.project_id)
}

# Deploy Cloud Run services in specified regions
resource "google_cloud_run_v2_service" "firepubauditsource" {
  project  = var.project_id
  location = var.region
  name     = "fpas-${var.name}"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  deletion_protection = false

  template {
    service_account = google_service_account.cloud_run_sa.email

    containers {
      image = "${var.artifact_registry_host}/${local.final_artifact_registry_project_id}/${var.artifact_registry_name}/unitvectory-labs/firepubauditsource:${var.firepubauditsource_tag}"

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "PUBSUB_TOPIC"
        value = google_pubsub_topic.firepubauditsource_topic.name
      }
    }
  }
}

# Service account for Eventarc triggers
resource "google_service_account" "eventarc_sa" {
  project      = var.project_id
  account_id   = "fpas-${var.name}"
  display_name = "firepubauditsource Eventarc (${var.name}) service account"
}

# IAM role to grant Eventarc event receiver permissions to Eventarc service account
resource "google_project_iam_member" "eventarc_event_receiver_role" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc_sa.email}"
}

# IAM role to grant invoke permissions to Eventarc service account for Cloud Run services
resource "google_cloud_run_service_iam_member" "invoke_permission" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_v2_service.firepubauditsource.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.eventarc_sa.email}"
}

# Eventarc trigger to invoke Cloud Run services on Firestore changes
resource "google_eventarc_trigger" "firestore_trigger" {
  project                 = var.project_id
  name                    = "fpas-${var.name}-${var.database_region}"
  location                = var.database_region
  service_account         = google_service_account.eventarc_sa.email
  event_data_content_type = "application/protobuf"

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.firestore.document.v1.written"
  }

  matching_criteria {
    attribute = "database"
    value     = var.database
  }

  destination {
    cloud_run_service {
      region  = var.region
      service = google_cloud_run_v2_service.firepubauditsource.name
      path    = "/firestore"
    }
  }

  depends_on = [google_project_iam_member.eventarc_event_receiver_role]
}
