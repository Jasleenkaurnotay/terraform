output "cert_arn" {
    value = data.aws_acm_certificate.issued_cert.arn
}