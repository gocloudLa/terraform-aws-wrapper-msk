/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* MSK | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "msk_parameters" {
  type        = any
  description = "Map of MSK cluster configurations to provision."
  default     = {}
}

variable "msk_defaults" {
  type        = any
  description = "Default values merged into each entry of msk_parameters."
  default     = {}
}
