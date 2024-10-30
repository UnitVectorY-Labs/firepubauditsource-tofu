[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Work In Progress](https://img.shields.io/badge/Status-Work%20In%20Progress-yellow)](https://guide.unitvectorylabs.com/bestpractices/status/#work-in-progress)

# firepubauditsource-tofu

A module for OpenTofu that deploys firepubauditsource to GCP Cloud Run, along with configuring essential services including Eventarc for Firestore and Pub/Sub.

## Usage

```hcl
module "firepubauditsource" {
    source = "git::https://github.com/UnitVectorY-Labs/firepubauditsource-tofu.git?ref=main"
    name                         = "firepub"
    project_id                   = var.project_id
    region                       = var.region
    artifact_registry_host       = "us-docker.pkg.dev"
    artifact_registry_name       = "ghcr"
    artifact_registry_project_id = var.project_id
    firepubauditsource_tag       = "dev"
    database                     = "(default)"
    database_region              = "nam5"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service_iam_member.invoke_permission](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloud_run_v2_service.firepubauditsource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_eventarc_trigger.firestore_trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/eventarc_trigger) | resource |
| [google_project_iam_member.eventarc_event_receiver_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.eventarc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.firestore](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.pubsub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_pubsub_topic.firepubauditsource_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.pubsub_publisher_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account.cloud_run_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.eventarc_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_registry_host"></a> [artifact\_registry\_host](#input\_artifact\_registry\_host) | The name of the Artifact Registry repository | `string` | `"us-docker.pkg.dev"` | no |
| <a name="input_artifact_registry_name"></a> [artifact\_registry\_name](#input\_artifact\_registry\_name) | The name of the Artifact Registry repository | `string` | n/a | yes |
| <a name="input_artifact_registry_project_id"></a> [artifact\_registry\_project\_id](#input\_artifact\_registry\_project\_id) | The project to use for Artifact Registry. Will default to the project\_id if not set. | `string` | `null` | no |
| <a name="input_database"></a> [database](#input\_database) | The Firestore database to monitor for changes | `string` | n/a | yes |
| <a name="input_database_region"></a> [database\_region](#input\_database\_region) | The Firestore database to monitor's region | `string` | n/a | yes |
| <a name="input_firepubauditsource_tag"></a> [firepubauditsource\_tag](#input\_firepubauditsource\_tag) | The tag for the firepubauditsource image to deploy | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the application (used for Cloud Run & Pub/Sub) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project id | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to deploy resources to | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

