{{/*
Expand the name of the chart.
*/}}
{{- define "fusionpbx.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fusionpbx.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fusionpbx.labels" -}}
helm.sh/chart: {{ include "fusionpbx.chart" . }}
{{ include "fusionpbx.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fusionpbx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fusionpbx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Chart name and version as used by the chart label.
*/}}
{{- define "fusionpbx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PostgreSQL Host
*/}}
{{- define "fusionpbx.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-postgresql" (include "fusionpbx.fullname" .) -}}
{{- else -}}
{{- .Values.postgresql.external.host -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL Port
*/}}
{{- define "fusionpbx.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
5432
{{- else -}}
{{- .Values.postgresql.external.port -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL User
*/}}
{{- define "fusionpbx.postgresql.user" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.username -}}
{{- else -}}
{{- .Values.postgresql.external.username -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL Password
*/}}
{{- define "fusionpbx.postgresql.password" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.password -}}
{{- else -}}
{{- .Values.postgresql.external.password -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL Database
*/}}
{{- define "fusionpbx.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database -}}
{{- else -}}
{{- .Values.postgresql.external.database -}}
{{- end -}}
{{- end -}}

{{/*
FreeSWITCH PostgreSQL DSN
*/}}
{{- define "fusionpbx.freeswitch.dsn" -}}
pgsql://hostaddr={{ include "fusionpbx.postgresql.host" . }} port={{ include "fusionpbx.postgresql.port" . }} dbname={{ include "fusionpbx.postgresql.database" . }} user={{ include "fusionpbx.postgresql.user" . }} password={{ include "fusionpbx.postgresql.password" . }}
{{- end -}}

{{/*
PostgreSQL Environment Variables from Secret
*/}}
{{- define "fusionpbx.postgresql.envs" -}}
{{- $secretName := default (printf "%s-postgresql-credentials" (include "fusionpbx.fullname" .)) .Values.postgresql.secret.name -}}
{{- $keys := .Values.postgresql.secret.keys -}}
- name: DATABASE_HOST
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ default "host" $keys.host }}
- name: DATABASE_PORT
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ default "port" $keys.port }}
- name: DATABASE_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ default "username" $keys.username }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ default "password" $keys.password }}
- name: DATABASE_NAME
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ default "database" $keys.database }}
{{- end -}}
