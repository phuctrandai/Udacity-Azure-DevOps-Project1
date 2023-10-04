# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
	default = "DevOps"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
	default = "East US"
}

variable "username" {
	description = "Username"
	default = "phuctd"
}

variable "password" {
	description = "Password"
	default = "Abcde12345-+"
}

variable "platform_fault_domain_count" {
	description = "azurerm_availability_set platform_fault_domain_count"
	default = 2
}

variable "platform_update_domain_count" {
	description = "azurerm_availability_set platform_update_domain_count"
	default = 5
}

variable "packer_image_name" {
  description = "Name of the Packer image"
  default     = "packer-image"
}

variable "packer_image_resource_group" {
	description = "Resource group name of Packer image"
	default = "packer-resources"
}