{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "elasticsearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "elasticsearch.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "elasticsearch.uname" -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-{{ .Values.nodeGroup }}
{{- else -}}
{{ .Values.nameOverride }}-{{ .Values.nodeGroup }}
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- end -}}


{{- define "elasticsearch.master.uname" -}}
{{ .Values.master.clusterName }}-{{ .Values.master.nodeGroup }}
{{- end -}}

{{- define "elasticsearch.data.uname" -}}
{{ .Values.data.clusterName }}-{{ .Values.data.nodeGroup }}
{{- end -}}

{{- define "elasticsearch.client.uname" -}}
{{ .Values.client.clusterName }}-{{ .Values.client.nodeGroup }}
{{- end -}}

{{- define "elasticsearch.commonname" -}}
{{ .Values.commonName }}
{{- end -}}


{{/*
Generate certificates
*/}}
{{- define "elasticsearch.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "elasticsearch.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "elasticsearch.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "elasticsearch-ca" 365 -}}
{{- $cert := genSignedCert ( include "elasticsearch.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | toString | b64enc }}
tls.key: {{ $cert.Key | toString | b64enc }}
ca.crt: {{ $ca.Cert | toString | b64enc }}
{{- end -}}

{{- define "elasticsearch.masterService" -}}
{{- if empty .Values.masterService -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-master
{{- else -}}
{{ .Values.nameOverride }}-master
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- else -}}
{{ .Values.masterService }}
{{- end -}}
{{- end -}}


{{- define "elasticsearch.master.endpoints" -}}
{{- $replicas := int (toString (.Values.master.replicas)) }}
{{- $uname := (include "elasticsearch.master.uname" .) }}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $uname }}-{{ $i }},
  {{- end -}}
{{- end -}}

{{- define "elasticsearch.esMajorVersion" -}}
{{- if .Values.esMajorVersion -}}
{{ .Values.esMajorVersion }}
{{- else -}}
{{- $version := int (index (.Values.imageTag | splitList ".") 0) -}}
  {{- if and (contains "docker.elastic.co/elasticsearch/elasticsearch" .Values.image) (not (eq $version 0)) -}}
{{ $version }}
  {{- else -}}
7
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Use the fullname if the serviceAccount value is not set
*/}}
{{- define "elasticsearch.serviceAccount" -}}
{{- .Values.rbac.serviceAccountName | default (include "elasticsearch.uname" .) -}}
{{- end -}}
