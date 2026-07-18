--[[
    MichalsInGameMods - FS25
    1) No speed limit  - tools work at any speed, top speed raised, cruise cap lifted
    2) Max capacity    - per-vehicle fill capacity overrides
    3) Max horsepower  - per-vehicle engine power overrides

    Vehicles matched by lowercase substring of their XML config path.
    Set DEBUG = true to print every vehicle's config path to log.txt,
    then tighten/fix patterns as needed.
]]

MIGM = {}

MIGM.DEBUG = false

-- ===========================================================================
-- CONFIG
-- ===========================================================================

-- No Speed Limit
MIGM.TOP_SPEED_MULTIPLIER = 2.0   -- factory top speed x this
MIGM.CRUISE_MAX_KMH       = 200

-- Max Capacity (liters)
MIGM.CAPACITY = {
    ["pacesetter"]  = 940000,  -- Wilson Pacesetter (base + Stevie)
    ["sks30"]       = 940000,  -- Krampe SKS 30 (base sks30_150 + Stevie)
    ["htw65"]       = 940000,  -- Bergmann HTW 65
    ["krone/gx"]    = 940000,  -- Krone GX (base)
    ["gx520"]       = 940000,  -- Krone GX 520 (Stevie)
    ["agriliner"]   = 940000,  -- Krone GX AgriLiner 520 (Stevie)
    ["krone/tx"]    = 940000,  -- Krone TX (base)
    ["krone/zx"]    = 940000,  -- Krone ZX (base)
    ["zx560"]       = 940000,  -- Krone ZX 560 GD (Stevie)
    ["rapide"]      = 940000,  -- Rapide 8400W (not installed yet)
    ["watertrailer1600"] = 60000, -- ABI 1600 water trailer (base)
    ["abi1600"]     = 60000,   -- ABI 1600 (Stevie mod variant)
    ["tdk301"]      = 60000,   -- TDK 301 RA + RP
}
MIGM.IGNORE_FILL_MASS = true  -- true = fill weight doesn't crush the physics

-- Max Horsepower (game hp / PS) — explicit per-vehicle overrides
MIGM.HORSEPOWER = {
    ["series9rx"] = 1156,  -- John Deere 9RX (base)
    ["9rxseries"] = 1156,  -- John Deere 9RX (Stevie)
    ["series9r"]  = 1156,  -- John Deere 9R (base)
    ["9rseries"]  = 1156,  -- John Deere 9R (Stevie)
    ["steiger"]   = 1156,  -- Case IH Steiger
    ["xerion"]    = 1156,  -- CLAAS XERION 12
    ["vnx"]       = 1156,  -- Volvo VNX 300
    ["anthem"]    = 1156,  -- Mack Anthem 6x4 (base + Stevie)
}

-- Blanket rule: every Large Tractor from these brands gets this hp.
-- Explicit HORSEPOWER patterns above win if both match (same value anyway).
MIGM.BIG_TRACTOR_HP = 1156
MIGM.BIG_TRACTOR_BRANDS = {
    JOHNDEERE = true,
    CASEIH    = true,
    CLAAS     = true,
    FENDT     = true,
}

-- ===========================================================================
-- helpers
-- ===========================================================================

local KW_PER_HP = 1 / 1.35962

local function matchVehicle(configFileName, tbl)
    local cfg = string.lower(configFileName or "")
    -- longest pattern wins, so overlapping patterns behave predictably
    local best, bestLen = nil, -1
    for pattern, value in pairs(tbl) do
        if string.find(cfg, pattern, 1, true) and #pattern > bestLen then
            best, bestLen = value, #pattern
        end
    end
    return best
end

-- ===========================================================================
-- 1) No Speed Limit
-- ===========================================================================

Vehicle.getSpeedLimit = Utils.overwrittenFunction(Vehicle.getSpeedLimit,
    function(self, superFunc, onlyIfWorking)
        return math.huge, false
    end
)

Drivable.onLoad = Utils.appendedFunction(Drivable.onLoad,
    function(self, savegame)
        local spec = self.spec_drivable
        if spec ~= nil and spec.cruiseControl ~= nil then
            local cc = spec.cruiseControl
            cc.maxSpeed = math.max(cc.maxSpeed or 0, MIGM.CRUISE_MAX_KMH)
            if cc.maxSpeedReverse ~= nil then
                cc.maxSpeedReverse = math.max(cc.maxSpeedReverse, MIGM.CRUISE_MAX_KMH)
            end
        end
    end
)

-- ===========================================================================
-- 2 + 3) Motorized hook: top speed boost (all vehicles) + horsepower (matched)
-- ===========================================================================

local function boostTopSpeed(motor, mult)
    if mult == nil or mult <= 1.0 then return end
    if motor.maxForwardSpeed ~= nil then
        motor.maxForwardSpeed = motor.maxForwardSpeed * mult
    end
    if motor.maxBackwardSpeed ~= nil then
        motor.maxBackwardSpeed = motor.maxBackwardSpeed * mult
    end
    if motor.minForwardGearRatio ~= nil then
        motor.minForwardGearRatio = motor.minForwardGearRatio / mult
    end
    if motor.minBackwardGearRatio ~= nil then
        motor.minBackwardGearRatio = motor.minBackwardGearRatio / mult
    end
end

-- Torque scaling via output override: survives any internal curve layout changes.
VehicleMotor.getTorqueCurveValue = Utils.overwrittenFunction(VehicleMotor.getTorqueCurveValue,
    function(self, superFunc, rpm)
        local v = superFunc(self, rpm)
        if v ~= nil and self.migmTorqueScale ~= nil then
            v = v * self.migmTorqueScale
        end
        return v
    end
)

-- Peak power in kW: use the field if it exists, otherwise sample the curve.
-- power(kW) = torque(kNm) * rpm * 2pi/60
local function getPeakPowerKw(motor)
    if motor.peakMotorPower ~= nil and motor.peakMotorPower > 0 then
        return motor.peakMotorPower
    end
    local maxRpm = motor.maxRpm or 2100
    local minRpm = motor.minRpm or 800
    local peak = 0
    for rpm = minRpm, maxRpm, 25 do
        local torque = motor:getTorqueCurveValue(rpm)
        if torque ~= nil then
            peak = math.max(peak, torque * rpm * 0.10472)
        end
    end
    if peak > 0 then return peak end
    return nil
end

local function setHorsepower(motor, targetHp)
    local targetKw = targetHp * KW_PER_HP
    local currentKw = getPeakPowerKw(motor)
    if currentKw == nil then
        print("MIGM: WARN could not determine current power, dumping motor keys:")
        local keys = {}
        for k in pairs(motor) do
            if type(k) == "string" then table.insert(keys, k) end
        end
        table.sort(keys)
        print("MIGM:   " .. table.concat(keys, ", "))
        return nil
    end

    motor.migmTorqueScale = targetKw / currentKw

    -- keep display-ish fields in sync where they exist
    if motor.peakMotorPower ~= nil then
        motor.peakMotorPower = targetKw
    end
    if motor.peakMotorTorque ~= nil then
        motor.peakMotorTorque = motor.peakMotorTorque * motor.migmTorqueScale
    end
    return currentKw, targetKw
end

-- Large-tractor blanket rule: category tractorsL + brand allowlist,
-- resolved via the store item so it works for base game and mod paths alike.
local function getBigTractorHp(vehicle)
    if MIGM.BIG_TRACTOR_HP == nil then return nil end
    if g_storeManager == nil then return nil end
    local item = g_storeManager:getItemByXMLFilename(vehicle.configFileName)
    if item == nil then return nil end

    local cat = string.lower(item.categoryName or "")
    if cat ~= "tractorsl" then return nil end

    local brandName = ""
    if item.brandIndex ~= nil and g_brandManager ~= nil then
        local brand = g_brandManager:getBrandByIndex(item.brandIndex)
        if brand ~= nil and brand.name ~= nil then
            brandName = string.upper(string.gsub(brand.name, "[%s%-]", ""))
        end
    end
    if MIGM.BIG_TRACTOR_BRANDS[brandName] == true then
        return MIGM.BIG_TRACTOR_HP
    end
    return nil
end

Motorized.onLoad = Utils.appendedFunction(Motorized.onLoad,
    function(self, savegame)
        local spec = self.spec_motorized
        if spec == nil or spec.motor == nil then return end

        if MIGM.DEBUG then
            local item = g_storeManager ~= nil
                and g_storeManager:getItemByXMLFilename(self.configFileName) or nil
            print("MIGM DEBUG motorized: " .. tostring(self.configFileName)
                .. " power=" .. tostring(spec.motor.peakMotorPower) .. " kW"
                .. " category=" .. tostring(item ~= nil and item.categoryName or "?")
                .. " brandIndex=" .. tostring(item ~= nil and item.brandIndex or "?"))
        end

        boostTopSpeed(spec.motor, MIGM.TOP_SPEED_MULTIPLIER)

        local hp = matchVehicle(self.configFileName, MIGM.HORSEPOWER)
            or getBigTractorHp(self)
        if hp ~= nil then
            local fromKw, toKw = setHorsepower(spec.motor, hp)
            if fromKw ~= nil then
                print(string.format("MIGM: %s -> %d hp (%.0f kW -> %.0f kW, scale %.2f)",
                    self.configFileName, hp, fromKw, toKw, spec.motor.migmTorqueScale))
            else
                print(string.format("MIGM: %s -> %d hp FAILED (see motor key dump above)",
                    self.configFileName, hp))
            end
        end
    end
)

-- ===========================================================================
-- 2) Max Capacity
-- ===========================================================================

FillUnit.onLoad = Utils.appendedFunction(FillUnit.onLoad,
    function(self, savegame)
        if MIGM.DEBUG then
            print("MIGM DEBUG fillunit: " .. tostring(self.configFileName))
        end

        local capacity = matchVehicle(self.configFileName, MIGM.CAPACITY)
        if capacity == nil then return end

        local spec = self.spec_fillUnit
        if spec == nil or spec.fillUnits == nil then return end

        local oldCap = 0
        for _, fillUnit in ipairs(spec.fillUnits) do
            if fillUnit.capacity ~= nil and fillUnit.capacity > 0 then
                oldCap = math.max(oldCap, fillUnit.capacity)
                fillUnit.capacity = capacity
                fillUnit.defaultCapacity = capacity
                if MIGM.IGNORE_FILL_MASS then
                    fillUnit.updateMass = false
                end
            end
        end

        print(string.format("MIGM: %s -> %d l (was %d l)", self.configFileName, capacity, oldCap))
    end
)

print("MichalsInGameMods loaded: speed limits off, top speed x"
    .. tostring(MIGM.TOP_SPEED_MULTIPLIER)
    .. ", capacity + horsepower overrides active")
