/*========================
EDIT BELOW
========================*/
var JSONUrl = "signshop.json";
var dynmapURL = "https://map.piratemc.com";
/*========================
EDIT ABOVE
========================*/

var ENCHANTS = {
    "ARROW_DAMAGE": "Power",
    "ARROW_FIRE": "Flame",
    "ARROW_INFINITE": "Infinity",
    "ARROW_KNOCKBACK": "Punch",
	"BINDING_CURSE": "Curse of Binding",
    "DAMAGE_ALL": "Sharpness",
    "DAMAGE_ARTHROPODS": "Bane of Arthropods",
    "DAMAGE_UNDEAD": "Smite",
    "DEPTH_STRIDER": "Depth Strider",
    "DIG_SPEED": "Efficiency",
    "DURABILITY": "Unbreaking",
    "FIRE_ASPECT": "Fire Aspect",
    "FROST_WALKER": "Frost Walker",
    "KNOCKBACK": "Knockback",
    "LOOT_BONUS_BLOCKS": "Fortune",
    "LOOT_BONUS_MOBS": "Looting",
    "LUCK": "Luck of the Sea",
    "LURE": "Lure",
    "MENDING": "Mending",
    "OXYGEN": "Respiration",
    "PROTECTION_ENVIRONMENTAL": "Protection",
    "PROTECTION_EXPLOSIONS": "Blast Protection",
    "PROTECTION_FALL": "Feather Falling",
    "PROTECTION_FIRE": "Fire Protection",
    "PROTECTION_PROJECTILE": "Projectile Protection",
    "SILK_TOUCH": "Silk Touch",
	"SWEEPING_EDGE": "Sweeping Edge",
	//The JSON has sweeping edge as "SWEEPING" instead of "SWEEPING_EDGE"
	"SWEEPING": "Sweeping Edge",
    "THORNS": "Thorns",
	"VANISHING_CURSE": "Curse of Vanishing",
    "WATER_WORKER": "Aqua Affinity"
}
var NUMERALS = {
    "1": "I",
    "2": "II",
    "3": "III",
    "4": "IV",
    "5": "V"
}
var sorted;
var signShopData;
var result;
var $select = $("#itemselect");
$.ajax({
    url: "items.json",
    dataType: "JSON",
    success: function (data) {
        sorted = _.sortBy(data, "name")
        $.each(sorted, function (key, val) {
            $select.append("<option value='" + val.type + ":" + val.meta + "'>" + val.name + "</option>");
        })
    },
    error: function () {
        $select.html("<option value=''>ERROR! Could not load items!</option>");
    }
});
$("#itemselect").select2({
    placeholder: "Choose an item",
    allowClear: true
});

$.ajax({
    url: JSONUrl,
    dataType: "JSON",
    success: function (data) {
        sortedbyprice = data.sort(function(a, b) {
            if (a.invItems == null || a.invItems.length == 0) return 1;
            if (b.invItems == null || b.invItems.length == 0) return -1;
            
            var priceRatioA = (a.signPrice / a.invItems[0].amount);
            var priceRatioB = (b.signPrice / b.invItems[0].amount);
            
            return priceRatioA - priceRatioB;
        });
	    
        JSONLength = data.length;
        $("#shop-number").text(JSONLength);
    },
    error: function () {
        alert("ERROR! Could not connect to the shop data!");
    }
});

function findshops() {
    var selecteditem = $('#itemselect option:selected').val();
    var itemname = $('#itemselect option:selected').text();
    var fields = selecteditem.split(/:/);
    var itemid = fields[0];
    var itemid2 = fields[1];
    var matches = [];
    var displayedmatches = [];
    $.each(sortedbyprice, function (key, val) {
		if (val.invItems == null) return;
        $.each(val.invItems, function (key2, val2) {
			
            var type = val2.type;
            var durability = val2.durability;
            if (type == itemid && durability == itemid2 && (val.signType == "buy" || val.signType == "sell" || val.signType == "ibuy" || val.signType == "isell")) {

                $("#2").text(val.amount);
               
                matches.push(val);

            }
        });

    });
    if (matches.length == 0) {
        $("#responsecontainer").addClass("hide");
        $("#1").text("Error! No shops found with that item!");
        $("#2").text("");
    } else {
        $("#responsecontainer").empty();
        $("#responsecontainer").removeClass("hide");
        $("#1").text("");
        $("#2").text("Fetched " + matches.length + " results. Displaying sorted by price.")
        $.each(matches, function (key3, val3) {

            $.each(val3.invItems, function (key4, val4) {
                if (val4.type != itemid || val4.durability != itemid2) {
                    return;
                }
                var $signtype = val3.signType;
                var $amount = val4.amount;
                var $signprice = val3.signPrice;
                var $ownername = val3.ownerName;
                var $locworld = val3.locWorld;
                var $x = val3.locX;
                var $y = val3.locY;
                var $z = val3.locZ;
                if ($signtype == "ibuy" || $signtype == "isell") {
                    var $invinstock = "infinite";
                } else {
                    var $invinstock = val3.invInStock;
                }
                var currentmatch = {
                    signType: $signtype,
                    amount: $amount,
                    signPrice: $signprice,
                    ownerName: $ownername,
                    locWorld: $locworld,
                    locX: $x,
                    locY: $y,
                    locZ: $z,
                    invInStock: $invinstock
                };

                displayedmatches.push(val3);

            });


        });

        matches.length = 0;


        $.each(displayedmatches, function (key5, val5) {
            $.each(val5.invItems, function (key6, val6) {
                

                var enchants = val6.meta.enchantments,
                    enchantLabels = [],
                    enchant = null,
                    level = null;
                for (enchant in enchants) {
                    level = enchants[enchant];
                    enchantLabels.push(ENCHANTS[enchant] + " " + NUMERALS[level]);

                }

                if (enchants == null) {
                    var displayedenchant = "none";
                } else {
                    var displayedenchant = enchantLabels.join(", ");
                }
                if (val5.signType == "ibuy" || val5.signType == "isell") {
                    var $invinstock = "infinite";
                } else {
                    var $invinstock = val5.invInStock;
                }
                if ($invinstock == false) {
                    var textColor = "red-text";
                } else {
                    var textColor = "green-text";
                }

                var $appendrow = $("<div class='col l3 m3 s6'><div class='card'><div class='card-image'><img src='img/" + itemid + "-" + itemid2 + ".png' class='card-image-size'><span class='card-title black-text right-align'>" + itemname + "</span></div><div class='card-content'><p><strong>Owner:</strong></p><img src='https://minotar.net/avatar/" + val5.ownerName + "/20' class='left'><p>" + val5.ownerName + "</p><p><strong>Enchantments:</strong></p><p>" + displayedenchant + "</p><p><strong>Location:</strong></p><p><i>" + val5.locWorld + "</i> @ <a href='" + dynmapURL + "/?worldname=" + val5.locWorld + "&mapname=surface&zoom=20&x=" + val5.locX + "&y=" + val5.locY + "&z=" + val5.locZ + "' target='_blank'>" + val5.locX + ", " + val5.locY + ", " + val5.locZ + "</a></p><p><strong>In Stock?: </strong><span class='" + textColor + "'>" + $invinstock + "</span></p></div><div class='card-action'><strong>" + val5.signType + "</strong> " + val6.amount + " for <strong>G" + val5.signPrice + "</strong></div></div></div>");
                $appendrow.appendTo("#responsecontainer");
            });



        });

    }
}
