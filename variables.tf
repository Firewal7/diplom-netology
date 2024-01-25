variable "token" {
  type        = string
  description = "Your Yandex.Cloud API token"
}

variable "cloud_id" {
  type        = string
  description = "Your Yandex.Cloud Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Your Yandex.Cloud Folder ID"
}

variable "yc_folder_id" {
  type        = string
  default     = "b1giheq958o43g020idm"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Default zone for resources"
}

variable "default_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

###yandex_compute_image vars
variable "public_image" {
  type        = string
  default     = "fd8pqclrbi85ektgehlf"
  description = "Yandex.Compute image ID"
}
###name VM vars
variable "public_name" {
  type        = string
  default     = "public"
  description = "VM1 name"
}

###public_resources var

variable "public_resources" {
  type = map(number)
  default = {
    cores          = 4
    memory         = 4
    core_fraction  = 100
 }
}
