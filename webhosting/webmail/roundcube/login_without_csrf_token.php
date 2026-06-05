<!DOCTYPE html>
<html><head><!--
  from https://github.com/mk-pmb/plesk-util-pmb
  save somewhere in /usr/share/psa-roundcube

  Is this safe to use? Not if you use fail2ban. RoundCube does rotate the
  CSRF token after login, so an attacker can't directly submit follow-up
  requests once you logged in. And since the password has to be provided
  by the attacker for a successful login via this script, they can only
  use accounts they could already log into themselves.
  In theory, when combined with a clickjack attack, that means they could
  make you download a file from one of their mail folders. Or submit a
  prepared draft for a spam email so the submission records your IP address
  instead of theirs.
  The more realistic risk though is that the attacker will make your browser
  send a lot of wrong password attempts, to provoke fail2ban to ban you.

  -->
  <meta charset="UTF-8">
  <title>RoundCube login helper</title>
  <meta http-equiv="Content-Script-Type" content="text/javascript">
</head><body>

<form method="post" action="/"><?php

$field_defaults = [
  '_token' => '',
  '_task' => 'login',
  '_action' => 'login',
  '_timezone' => 'Europe/Berlin',
  '_url' => '',
  '_user' => '',
  '_pass' => '',
];

foreach ($field_defaults as $key => $dflt) {
  $val = @$_REQUEST[$key];
  if (!isset($val)) { $val = $dflt; }
  $val = (string)$val;
  echo PHP_EOL, '<input type="hidden" name="', $key, '" value="',
    htmlspecialchars($val, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'), '">';
}

?>
</form>

<script>
'use strict';
(async function getToken() {
  let token = await fetch('/');
  token = await token.text();
  token = String(token).replace(/\s+/g, ' ');
  token = token.split('<input type="hidden" name="_token" value="')[1];
  token = (token || '').split('"')[0];
  if (!token) { return; }
  const form = document.forms[0];
  form.elements['_token'].value = token;
  form.submit();
}());
</script>

</body></html>
