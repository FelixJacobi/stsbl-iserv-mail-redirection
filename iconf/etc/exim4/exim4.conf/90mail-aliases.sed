/^\s*begin routers/a \
\
  # Umleitungen, die über den IDesk definiert wurden, verarbeiten.\
  idesk_aliases:\
    driver = redirect\
    allow_fail\
    allow_defer\
    # only apply for local domains\
    domains = +local_domains\
    # local part must not have an equivalent user account\
    condition = ${if !eq {${lookup pgsql{ SELECT 1 FROM users WHERE Act = \\\
      '${quote_pgsql:$local_part}' LIMIT 1 }}} {1}}\
    # local part must not have an equivalent group account\
    condition = ${if !eq {${lookup pgsql{ SELECT 1 FROM groups WHERE Act = \\\
      '${quote_pgsql:$local_part}' LIMIT 1 }}} {1}}\
    condition = ${if eq {${lookup pgsql{ SELECT 1 FROM mailredirection_addresses a \\\
      WHERE a.recipient = '${quote_pgsql:$local_part}' AND enabled = true \\\
      AND (EXISTS (SELECT 1 FROM mailredirection_recipient_users u WHERE \\\
      u.original_recipient_id = a.id) OR EXISTS (SELECT 1 \\\
      FROM mailredirection_recipient_groups g WHERE g.original_recipient_id = \\\
      a.id)) }}} {1}}\
    data = ${lookup pgsql{ SELECT recipient FROM mailredirection_recipient_users u \\\
      WHERE u.original_recipient_id IN (SELECT id FROM mailredirection_addresses a \\\
      WHERE a.recipient = '${quote_pgsql:$local_part}') UNION \\\
      SELECT recipient FROM mailredirection_recipient_groups g WHERE \\\
      g.original_recipient_id IN (SELECT id FROM mailredirection_addresses a \\\
      WHERE a.recipient = '${quote_pgsql:$local_part}') }}
