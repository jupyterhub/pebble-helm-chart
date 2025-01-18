{{/* vim: set filetype=mustache: */}}

{{/*
Extracts a component name from active template's filename to
create a suffix, so for a file named "coredns-configmap.yaml",
the extracted suffix becomes "-coredns" and a file named
"pebble-configmap.yaml" the extracted suffix becomes "".
*/}}
{{- define "pebble.componentSuffix" }}
{{- $names_in_filename := .Template.Name | base | trimSuffix ".yaml" | splitList "-" | initial }}
{{- $names_in_filename := without $names_in_filename "pebble" }}
{{- prepend $names_in_filename "" | join "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
If release name contains chart name it will be used as
a full name.
*/}}
{{- define "pebble.fullname" -}}
{{ print (include "pebble.fullnameHelper" .) (include "pebble.componentSuffix" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "pebble.fullnameHelper" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride }}
{{- else }}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name }}
{{- end }}
{{- end }}
{{- end }}

{{/* Selector labels */}}
{{- define "pebble.selectorLabels" -}}
app.kubernetes.io/name: {{ print .Chart.Name (include "pebble.componentSuffix" .) | trunc 63 | trimSuffix "-" }}
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
