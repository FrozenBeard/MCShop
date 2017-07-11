## MCSHOPDEX by LAKEN HAFNER
## (c) 2017
## AVAILABLE UNDER THE MIT LICENSE
## PROJECT HOMEPAGE: HTTPS://GITLAB.COM/LAKEN/MCSHOPDEX/

# creating a few variables, setting them to null for now
symbol = null
dynmapURL = null

# on page load, starts all other functions
$ ->
	# loading our config
	$.getJSON 'config.json', (configData) ->
		console.log "Recieved Config..."
		# assigning each key's value in the config to a variable
		name = configData.shopdexName
		ip = configData.serverIP
		json = configData.shopData
		dynmapURL = configData.dynmapURL
		itemApi = configData.itemAPI
		symbol = configData.currencySymbol
		# filling blanks spots with the variables we set
		$('#shopdexName').text name
		$('#shopdexIp').text ip
		# now we're going to grab data about the server...
		getServerData ip
		# going to load item api now...
		idItems itemApi, (itemNames) ->
			# while we are still dealing with the config, we need to load the shopdata
			loadShopData json, itemNames
		

getServerData = (ip) ->
	# using https://mcapi.ca/ 
	# first going to check if the server specified is online or not...
	$.getJSON 'https://mcapi.ca/query/' + ip + '/info', (serverData) ->
		status = serverData.status
		version = serverData.version
		if status is true 
			# because it defaults to red text saying `Offline` we are removing the red text class, adding the green one, and replacing text contents
			$('#shopdexStatusColor').removeClass 'red-text'
			$('#shopdexStatusColor').addClass 'green-text'
			$('#shopdexStatus').text 'Online'
			$('#shopdexVersion').text version
		# changing displayed picture to the official server one...
		$('#shopdexImage').attr 'src', 'https://mcapi.ca/query/' + ip + '/icon'
		console.log "Loaded Config!"

idItems = (itemApi, callback) ->
	$.getJSON itemApi, (items) ->	
		console.log "Recieved Item JSON..."
		itemIds = {}								
		for itemData, itemDataVal of items
			# here we're turning the array of objects into an easier format.. plain 'ol array
			itemId = itemDataVal.type + ":" + itemDataVal.meta
			itemIds[itemId] = itemDataVal.name.toLowerCase()
		console.log "Converted Item JSON!"
		console.log itemIds
		callback itemIds

shops = []
loadShopData = (json, itemNames) ->
	
	$.getJSON json, (jsonData) ->
		console.log "Recieved Shop JSON..."
		# because of the way the json is structured, we have to nest all of these loops
		# i know it's horrible
		validSigns = ["buy", "sell", "ibuy", "isell"]
		for root, rootVal of jsonData
			if rootVal.invItems.length < 2
			# now we're checking for if there are multiple items sold in a shop
			# less than 2 objects in InvItems means that it isn't a multi-item shop
				multiShop = false
			else
				multiShop = true
				shopGroup = []
				for invItems, invItemsVal of rootVal.invItems
					if rootVal.signType in validSigns
						# looping through the invitems to grab the name and amount of each item sold @ the same shop
						# atm we only grab those 2, so any meta values (such as enchantments) are not recorded there.. might fix in the future
						shopGroupItemId = invItemsVal.type + ":" + invItemsVal.durability
						shopGroup.push invItemsVal.amount + " " + itemNames[shopGroupItemId]
				multiShopItems = shopGroup.join(', ')

			for invItems, invItemsVal of rootVal.invItems
				if rootVal.signType in validSigns
					# this makes it much easier to work with the data, can go through all this only once instead of during every damn search
					shop = {}
					shop.itemId = invItemsVal.type + ":" + invItemsVal.durability
					shop.name = itemNames[shop.itemId]
					shop.type = rootVal.signType
					shop.price = rootVal.signPrice
					shop.amount = invItemsVal.amount
					shop.owner = rootVal.ownerName
					shop.owner = "Server" if shop.type is "ibuy" or shop.type is "isell"
					shop.stock = rootVal.invInStock
					shop.stock = "infinite" if shop.type is "ibuy" or shop.type is "isell"
					shop.world = rootVal.locWorld
					shop.x = rootVal.locX
					shop.y = rootVal.locY
					shop.z = rootVal.locZ
					shop.enchants = null;
					if invItemsVal.meta
						if invItemsVal.meta.enchantments
							enchantList = [] 
							for enchant, level of invItemsVal.meta.enchantments
								# turning the enchants into a more familiar format...
								enchantList.push ENCHANTS[enchant] + " " + NUMERALS[level]
							# if multiple enchantments, we are joining them together with a comma and a space ;)
							shop.enchants = enchantList.join(', ')
					shop.multi = multiShopItems if multiShop isnt false

					if shop.multi or shop.enchants
						shop.hasMeta = true

					shops.push shop
		shops = shops.sort (a, b) ->
			# defaulting to sorting by price, in the future this may be a search option..
			pricePerA = a.price / a.amount
			pricePerB = b.price / b.amount
			pricePerA - pricePerB
		console.log shops
		console.log "Loaded Shops!"
		$('#loadingSpinner').hide()
		$('#itemSearchBox').removeAttr 'disabled'
		$('#playerSearchBox').removeAttr 'disabled'

$('#itemSearchBox').on 'input', () ->
	# this function searches the data based on itemname provided on each value change in the input
	$('#results').html ""
	$('#playerSearchBox').val ""
	search = $('#itemSearchBox').val().toLowerCase()
	$('#resultsLabel').show()
	$('#query').text search
	
	for searchShop, shop of shops
		if shop.enchants
			enchantSearch = shop.enchants.toLowerCase()
			if shop.name and shop.name.includes(search) or enchantSearch.includes(search)
				generateResults shop
		else
			if shop.name and shop.name.includes(search)
				generateResults shop

$('#playerSearchBox').on 'input', () ->
	# this function searches the data based on playername provided on each value change in the input
	$('#results').html ""
	$('#itemSearchBox').val ""
	search = $('#playerSearchBox').val().toLowerCase()
	$('#resultsLabel').show()
	$('#query').text search

	for searchShop, shop of shops
		shopOwner = shop.owner.toLowerCase()
		if shopOwner and shopOwner.includes(search)
			generateResults shop

generateResults = (shop) ->
	# this function generates results from the shop given to it
	if shop.stock is true
		color = 'green-text'
		inStock = 'In Stock'
	else
		if shop.stock is "infinite"
			color = 'green-text'
			inStock = '&infin; Stock'
		else
			color = 'red-text'
			inStock = 'No Stock'

	shopImage = shop.itemId.replace ':', '-'

	playerHead = "https://mcapi.ca/avatar/" + shop.owner
	if shop.owner is "Server"
		playerHead = "https://mcapi.ca/query/" + $('#shopdexIp').text() + "/icon/" 

	if shop.enchants
		enchantDisplay = "<p>Enchanted with<em> " + shop.enchants + "</em></p>"
	else
		enchantDisplay = ""
	if shop.multi
		multiDisplay = "<p>Includes<em> " + shop.multi + "</em></p>"
	else
		multiDisplay = ""

	if shop.hasMeta is true
		$('#results').append """
		<div class="result">
			<img class="result-image" src="img/#{ shopImage }.png" alt="#{ shop.name }">
			<div class="result-info">
				<p><strong>#{ shop.type }</strong> #{ shop.amount } #{ shop.name } for #{ symbol }#{ shop.price }</p>
				<p><span class="#{ color }">#{ inStock }</span> @ <a href="#{ dynmapURL + "?worldname=" + shop.world + "&mapname=surface&zoom=20&x=" + shop.x + "&y=" + shop.y + "&z=" + shop.z }" target="_blank">x#{ shop.x }, y#{ shop.y }, z#{ shop.z }</a>
				<p><i class="icon-globe"></i> #{ shop.world } &nbsp; <button class="show-on-mobile show-more-info">More Details</button><small class="show-on-desktop">Hover to See More Details</small></p>
				<div class="result-player"><img src="#{ playerHead }" width="30px" height="30px"><p> #{ shop.owner }</p></div>
				<div class="result-more-info">
					#{ enchantDisplay }
					#{ multiDisplay }
				</div>
			</div>
		</div>
		"""
	else
		$('#results').append """
		<div class="result">
			<img class="result-image" src="img/#{ shopImage }.png" alt="#{ shop.name }">
			<div class="result-info">
				<p><strong>#{ shop.type }</strong> #{ shop.amount } #{ shop.name } for #{ symbol }#{ shop.price }</p>
				<p><span class="#{ color }">#{ inStock }</span> @ <a href="#{ dynmapURL + "?worldname=" + shop.world + "&mapname=surface&zoom=20&x=" + shop.x + "&y=" + shop.y + "&z=" + shop.z }" target="_blank">x#{ shop.x }, y#{ shop.y }, z#{ shop.z }</a>
				<p><i class="icon-globe"></i> #{ shop.world }</p>
				<div class="result-player"><img src="#{ playerHead }" width="30px" height="30px"><p> #{ shop.owner }</p></div>
			</div>
		</div>
		"""

# enchant and numerals clean names below
ENCHANTS = 
  'ARROW_DAMAGE': 'Power'
  'ARROW_FIRE': 'Flame'
  'ARROW_INFINITE': 'Infinity'
  'ARROW_KNOCKBACK': 'Punch'
  'BINDING_CURSE': 'Curse of Binding'
  'DAMAGE_ALL': 'Sharpness'
  'DAMAGE_ARTHROPODS': 'Bane of Arthropods'
  'DAMAGE_UNDEAD': 'Smite'
  'DEPTH_STRIDER': 'Depth Strider'
  'DIG_SPEED': 'Efficiency'
  'DURABILITY': 'Unbreaking'
  'FIRE_ASPECT': 'Fire Aspect'
  'FROST_WALKER': 'Frost Walker'
  'KNOCKBACK': 'Knockback'
  'LOOT_BONUS_BLOCKS': 'Fortune'
  'LOOT_BONUS_MOBS': 'Looting'
  'LUCK': 'Luck of the Sea'
  'LURE': 'Lure'
  'MENDING': 'Mending'
  'OXYGEN': 'Respiration'
  'PROTECTION_ENVIRONMENTAL': 'Protection'
  'PROTECTION_EXPLOSIONS': 'Blast Protection'
  'PROTECTION_FALL': 'Feather Falling'
  'PROTECTION_FIRE': 'Fire Protection'
  'PROTECTION_PROJECTILE': 'Projectile Protection'
  'SILK_TOUCH': 'Silk Touch'
  'SWEEPING': 'Sweeping Edge'
  'THORNS': 'Thorns'
  'VANISHING_CURSE': 'Curse of Vanishing'
  'WATER_WORKER': 'Aqua Affinity'
NUMERALS = 
  '1': 'I'
  '2': 'II'
  '3': 'III'
  '4': 'IV'
  '5': 'V'
