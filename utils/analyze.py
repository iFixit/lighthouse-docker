import json

# Parse out scores from lighthouse json output

f = open('output0.json')

j = json.load(f)

a = j['audits']

for auditId, auditObj in a.items():
  sdm = auditObj['scoreDisplayMode']
  s = auditObj['score']
  if (sdm == 'binary' or sdm == 'numeric') and s < 1:
    print(auditId)
    print(auditObj['scoreDisplayMode'])
    print(auditObj['score'])
