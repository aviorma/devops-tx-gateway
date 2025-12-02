{{- define "tx-gateway.name" -}}
{{ default .Chart.Name .Values.nameOverride }}
{{- end -}}

{{- define "tx-gateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{ .Values.fullnameOverride }}
{{- else -}}
{{- $name := include "tx-gateway.name" . -}}
{{- printf "%s-%s" $name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "tx-gateway.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "tx-gateway.labels" -}}
helm.sh/chart: {{ include "tx-gateway.chart" . }}
app.kubernetes.io/name: {{ include "tx-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "tx-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tx-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
