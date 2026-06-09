/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Variable Definition                                                  */
/*----------------------------------------------------------------------*/

variable "msk_parameters" {
  type        = any
  description = ""
  default     = {}
}

variable "msk_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}
