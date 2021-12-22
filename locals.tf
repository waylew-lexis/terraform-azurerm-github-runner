locals {
  name = lower(var.runner_name)

  vpn_ranges = {
    "Alpharetta"                  = "66.241.32.0/19"
    "BocaRaton"                   = "209.243.48.0/20"
    "RBI_VPN_Chicago"             = "199.212.219.8/32"
    "ThreatMetrix_Sacramento_VPN" = "192.225.156.160/32"
    "UK"                          = "89.149.148.0/24"
    "UK_NGD"                      = "77.67.50.160/28"
    "UK_NTT"                      = "83.231.190.16/28"
    "UK_NTT2"                     = "83.231.235.0/24"
    "India"                       = "103.231.79.16/28"
    "London_1"                    = "145.43.254.22/31"
    "London_2"                    = "145.43.254.24/29"
  }
}
