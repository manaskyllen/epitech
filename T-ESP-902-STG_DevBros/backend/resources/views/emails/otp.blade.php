<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Votre code de vérification</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        /* Reset basique */
        body, html {
            margin: 0;
            padding: 0;
            background-color: #f8f9fb;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #333;
        }

        .container {
            max-width: 480px;
            margin: 40px auto;
            background: #ffffff;
            border-radius: 12px;
            padding: 30px 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            text-align: center;
        }

        h1 {
            font-size: 20px;
            margin-bottom: 20px;
            color: #111827;
        }

        .otp {
            font-size: 32px;
            letter-spacing: 8px;
            font-weight: bold;
            color: #2563eb;
            margin: 20px 0;
            padding: 12px 20px;
            background: #f0f6ff;
            border-radius: 8px;
            display: inline-block;
        }

        p {
            font-size: 14px;
            color: #555;
            line-height: 1.6;
        }

        .footer {
            margin-top: 25px;
            font-size: 12px;
            color: #999;
        }

        /* Responsive */
        @media (max-width: 600px) {
            .container {
                margin: 20px;
                padding: 20px 15px;
            }

            h1 {
                font-size: 18px;
            }

            .otp {
                font-size: 26px;
                letter-spacing: 6px;
                padding: 10px 15px;
            }

            p {
                font-size: 13px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Votre code de vérification</h1>
        <p>Utilisez le code ci-dessous pour finaliser votre connexion ou valider votre opération :</p>

        <div class="otp">{{ $otp }}</div>

        <p>Ce code est valable pour une durée limitée (2 minutes).<br>
        Si vous n’avez pas fait cette demande, ignorez simplement ce message.</p>

        <div class="footer">
            &copy; {{ date('Y') }} Inspiria. Tous droits réservés.
        </div>
    </div>
</body>
</html>
