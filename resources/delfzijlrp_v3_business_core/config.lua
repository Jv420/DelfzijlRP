Config = {}

Config.Command = 'bedrijf'
Config.DefaultBalance = 0
Config.DefaultTaxRate = 21

Config.Types = {
    retail = 'Winkel',
    vehicle = 'Voertuigen',
    horeca = 'Horeca',
    service = 'Dienstverlening',
    public = 'Overheid',
    transport = 'Transport'
}

Config.DefaultBusinesses = {
    { id = 'action', label = 'Action Delfzijl', type = 'retail' },
    { id = 'piricars', label = 'Piricars', type = 'vehicle' },
    { id = 'de2kolommer', label = 'De2Kolommer Delfzijl', type = 'service' },
    { id = 'alanya', label = 'Alanya', type = 'horeca' },
    { id = 'sharazan', label = 'Sharazan', type = 'horeca' },
    { id = 'milas', label = "Mila's Foodtruck", type = 'horeca' },
    { id = 'cafe_centrum', label = 'Cafe Centrum', type = 'horeca' },
    { id = 'stad_lande', label = 'Stad en Lande', type = 'horeca' },
    { id = 'taxi', label = 'Delfzijl Taxi', type = 'transport' },
    { id = 'coffeeshop_ng', label = 'Coffeeshop New Generation', type = 'retail' }
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot dit bedrijf.',
    notFound = 'Bedrijf niet gevonden.',
    created = 'Bedrijf aangemaakt.',
    updated = 'Bedrijf bijgewerkt.',
    invalid = 'Ongeldige invoer.'
}
