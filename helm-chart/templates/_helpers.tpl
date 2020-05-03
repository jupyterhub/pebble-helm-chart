{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
If release name contains chart name it will be used as
a full name.
*/}}
{{- define "pebble.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Selector labels */}}
{{- define "pebble.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Common labels */}}
{{- define "pebble.labels" -}}
{{ include "pebble.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "pebble.domains" -}}
{{- $name := include "pebble.fullname" . -}}
{{- $ns := .Release.Namespace -}}
localhost,
{{- $name }},
{{- $name }}.{{ $ns }},
{{- $name }}.{{ $ns }}.svc,
{{- $name }}.{{ $ns }}.svc.cluster.local
{{- end }}
