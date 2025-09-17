-- API module for external compatibility data sources
-- This module handles integration with web.dev baseline API

local M = {}

M.config = {
  webstatus_api_base = 'https://api.webstatus.dev/v1/features',
  timeout = 5000,
  cache_ttl = 3600
}

local cache = {}

local function is_cache_valid(key)
  local entry = cache[key]
  if not entry then
    return false
  end

  local current_time = os.time()
  return (current_time - entry.timestamp) < M.config.cache_ttl
end

local function set_cache(key, data)
  cache[key] = {
    data = data,
    timestamp = os.time()
  }
end

local function get_cache(key)
  if is_cache_valid(key) then
    return cache[key].data
  end
  return nil
end

local function make_http_request(url)
  local cmd = string.format('curl -s --max-time %d "%s"',
    math.floor(M.config.timeout / 1000), url)

  local handle = io.popen(cmd)
  if not handle then
    return nil, "Failed to execute curl command"
  end

  print("Running curl:", cmd)
  local result = handle:read("*a")
  print("Raw result:", result)
  local ok, reason, code = handle:close()

  if not ok then
    if code == 6 then
      return nil, "Could not resolve host (network/DNS issue)"
    elseif code == 7 then
      return nil, "Failed to connect to host (connection refused)"
    elseif code == 28 then
      return nil, "Request timeout"
    else
      return nil, string.format("HTTP request failed (%s, code %s)", reason or "unknown", code or "unknown")
    end
  end

  if not result or result == "" then
    return nil, "Empty response from API"
  end

  local pcallOke, response = pcall(vim.fn.json_decode, result)
  if not pcallOke then
    return nil, "Failed to parse JSON response: " .. (response or "unknown error")
  end

  return response, nil
end

function M.fetch_feature_by_id(feature_id)
  local cache_key = 'webstatus_id_' .. feature_id
  local cached = get_cache(cache_key)

  if cached then
    return cached
  end

  local url = string.format('%s?q=id:%s', M.config.webstatus_api_base, feature_id)
  local response, err = make_http_request(url)

  if err then
    local baseline_status = 'limited_availability'
    local description = feature_id

    local baseline_properties = {
      'transition', 'transform', 'border-radius', 'box-shadow', 'opacity',
      'position', 'color', 'background', 'margin', 'padding', 'width', 'height',
      'font-size', 'font-family', 'display', 'flex', 'grid'
    }

    for _, prop in ipairs(baseline_properties) do
      if feature_id == prop or string.find(feature_id, prop) then
        baseline_status = 'widely_available'
        description = 'Common CSS property with wide browser support'
        break
      end
    end
    
    local mock_response = {
      features = {
        {
          feature_id = feature_id,
          name = feature_id,
          baseline = {
            status = baseline_status
          },
          browser_implementations = {
            chrome = { status = 'available' },
            firefox = { status = 'available' },
            safari = { status = 'available' },
            edge = { status = 'available' }
          },
          description = description
        }
      }
    }
    set_cache(cache_key, mock_response)
    return mock_response
  end

  set_cache(cache_key, response)
  return response
end

function M.get_mock_features_by_status(status)
  local mock_features = {}

  if status == 'widely' then
    mock_features = {
      {
        feature_id = 'css-grid',
        name = 'CSS Grid Layout',
        baseline = { status = 'widely' },
        baseline_category = 'widely',
        browser_implementations = {
          chrome = { status = 'available', version = '57' },
          firefox = { status = 'available', version = '52' },
          safari = { status = 'available', version = '10.1' },
          edge = { status = 'available', version = '16' }
        }
      },
      {
        feature_id = 'css-flexbox',
        name = 'CSS Flexible Box Layout',
        baseline = { status = 'widely' },
        baseline_category = 'widely',
        browser_implementations = {
          chrome = { status = 'available', version = '29' },
          firefox = { status = 'available', version = '28' },
          safari = { status = 'available', version = '9' },
          edge = { status = 'available', version = '12' }
        }
      },
      {
        feature_id = 'css-transitions',
        name = 'CSS Transitions',
        baseline = { status = 'widely' },
        baseline_category = 'widely',
        browser_implementations = {
          chrome = { status = 'available', version = '26' },
          firefox = { status = 'available', version = '16' },
          safari = { status = 'available', version = '9' },
          edge = { status = 'available', version = '12' }
        }
      }
    }
  elseif status == 'newly' then
    mock_features = {
      {
        feature_id = 'css-aspect-ratio',
        name = 'CSS aspect-ratio property',
        baseline = { status = 'newly' },
        baseline_category = 'newly',
        browser_implementations = {
          chrome = { status = 'available', version = '88' },
          firefox = { status = 'available', version = '89' },
          safari = { status = 'available', version = '15' },
          edge = { status = 'available', version = '88' }
        }
      },
      {
        feature_id = 'css-gap-flexbox',
        name = 'CSS gap property in Flexbox',
        baseline = { status = 'newly' },
        baseline_category = 'newly',
        browser_implementations = {
          chrome = { status = 'available', version = '84' },
          firefox = { status = 'available', version = '63' },
          safari = { status = 'available', version = '14.1' },
          edge = { status = 'available', version = '84' }
        }
      }
    }
  elseif status == 'limited' then
    mock_features = {
      {
        feature_id = 'css-container-queries',
        name = 'CSS Container Queries',
        baseline = { status = 'limited' },
        baseline_category = 'limited',
        browser_implementations = {
          chrome = { status = 'available', version = '105' },
          firefox = { status = 'available', version = '110' },
          safari = { status = 'available', version = '16.0' },
          edge = { status = 'available', version = '105' }
        }
      },
      {
        feature_id = 'css-subgrid',
        name = 'CSS Subgrid',
        baseline = { status = 'limited' },
        baseline_category = 'limited',
        browser_implementations = {
          chrome = { status = 'unavailable' },
          firefox = { status = 'available', version = '71' },
          safari = { status = 'available', version = '16.0' },
          edge = { status = 'unavailable' }
        }
      }
    }
  end

  return mock_features
end

function M.fetch_features_by_baseline_status(status)
  local cache_key = 'webstatus_baseline_' .. status
  local cached = get_cache(cache_key)

  if cached then
    return cached
  end

  local features = {}
  local url = string.format('%s?q=baseline_status:%s', M.config.webstatus_api_base, status)
  local next_page_token = nil
  local page = 1
  local total = nil

  repeat
    local qualified_url = url

    if next_page_token then
      qualified_url = qualified_url .. "&page_token=" .. tostring(next_page_token)
    end

    print('Attempting to fetch from: ' .. qualified_url)

    local response, err = make_http_request(qualified_url)

    if err then
      print('Failed to fetch ' .. status .. ' baseline features: ' .. err)
      print('Note: API might be blocked by firewall. Using fallback data.')

      local mock_response = {
        features = M.get_mock_features_by_status(status)
      }
      set_cache(cache_key, mock_response)
      return mock_response
    end

    -- Collect entries
    if response and response.data then
      for _, entry in ipairs(response.data) do
        table.insert(features, entry)
      end
    end

    total = response and response.metadata and response.metadata.total
    next_page_token = response and response.metadata and response.metadata.next_page_token
    page = page + 1

  until not next_page_token

  local result = { features = features, total = total }
  set_cache(cache_key, result)

  return result
end

function M.fetch_all_baseline_features()
  print('Fetching all baseline features from web.dev API...')
  local all_features = {}
  local statuses = {'widely', 'limited', 'newly'}

  for _, status in ipairs(statuses) do
    print('Fetching ' .. status .. ' baseline features...')
    local response = M.fetch_features_by_baseline_status(status)
    if response and response.features then
      print(string.format('Found %d %s baseline features', #response.features, status))

      for _, feature in ipairs(response.features) do
        feature.baseline_category = status
        all_features[feature.feature_id] = feature
      end
    else
      print('No ' .. status .. ' baseline features found')
    end
  end

  return all_features
end

function M.save_features_to_json(features_data)
  local nvim_config_path = vim.fn.stdpath('config')
  local baseline_data_dir = nvim_config_path .. '/lua/baseline-checker'
  local json_file = baseline_data_dir .. '/features_data.json'

  local json_string = vim.fn.json_encode(features_data)

  local file = io.open(json_file, 'w')
  if file then
    file:write(json_string)
    file:close()
    print('Features data saved to ' .. json_file)
    return true
  else
    print('Failed to save features data to ' .. json_file)
    return false
  end
end

function M.load_features_from_json()
  local nvim_config_path = vim.fn.stdpath('config')
  local json_file = nvim_config_path .. '/lua/baseline-checker/features_data.json'

  local file = io.open(json_file, 'r')
  if not file then
    return nil
  end

  local content = file:read('*a')
  file:close()

  if content and content ~= '' then
    local ok, features_data = pcall(vim.fn.json_decode, content)
    if ok then
      return features_data
    end
  end

  return nil
end

function M.convert_webstatus_feature_to_compat_data(feature)
  if not feature then
    return nil
  end

  local status = 'unknown'
  local baseline = false

  if feature.baseline and feature.baseline.status then
    if feature.baseline.status == 'widely' or feature.baseline_category == 'widely' then
      status = 'supported'
      baseline = true
    elseif feature.baseline.status == 'newly' or feature.baseline_category == 'newly' then
      status = 'limited'
      baseline = false
    elseif feature.baseline.status == 'limited' or feature.baseline_category == 'limited' then
      status = 'limited'
      baseline = false
    else
      status = 'experimental'
      baseline = false
    end
  end

  local support = {
    chrome = 'unknown',
    firefox = 'unknown',
    safari = 'unknown',
    edge = 'unknown'
  }

  if feature.browser_implementations then
    local browser_map = {
      chrome = 'chrome',
      firefox = 'firefox',
      safari = 'safari',
      edge = 'edge'
    }

    for api_browser, internal_browser in pairs(browser_map) do
      if feature.browser_implementations[api_browser] then
        local impl = feature.browser_implementations[api_browser]
        if impl.status == 'available' then
          support[internal_browser] = impl.version or 'supported'
        elseif impl.status == 'experimental' then
          support[internal_browser] = 'experimental'
        else
          support[internal_browser] = 'not supported'
        end
      end
    end
  end

  return {
    baseline = baseline,
    support = support,
    status = status,
    description = feature.name or ('Web platform feature: ' .. (feature.feature_id or 'unknown')),
    feature_id = feature.feature_id,
    baseline_category = feature.baseline_category
  }
end


function M.test_api_connectivity()
  print('Testing API connectivity...')
  local url = M.config.webstatus_api_base .. '?q=baseline_status:widely'
  local _, err = make_http_request(url)

  if err then
    print('API test failed: ' .. err)
    return false
  else
    print('API test successful!')
    return true
  end
end

function M.update_compatibility_data()
  print('Updating compatibility data from web.dev API...')

  vim.defer_fn(function()
    local all_features = M.fetch_all_baseline_features()
    if all_features and next(all_features) then
      local feature_count = 0
      for _ in pairs(all_features) do
        feature_count = feature_count + 1
      end

      print(string.format('Found %d total baseline features', feature_count))

      local saved = M.save_features_to_json(all_features)

      if saved then
        local compat_data = require('baseline-checker.compat_data')
        compat_data.load_from_api_data(all_features)

        print('Compatibility data updated successfully!')
        print('Features data saved locally for offline use')
      else
        print('Failed to save features data locally')
      end
    else
      print('No features data found from API')
      print('This might be due to network restrictions or API being unavailable')
      print('Using fallback data from local hardcoded properties')
    end
  end, 1000)
end

function M.clear_cache()
  cache = {}
  print('API cache cleared')
end

function M.get_cache_stats()
  local count = 0
  local oldest = nil
  local newest = nil

  for _, entry in pairs(cache) do
    count = count + 1
    if not oldest or entry.timestamp < oldest then
      oldest = entry.timestamp
    end
    if not newest or entry.timestamp > newest then
      newest = entry.timestamp
    end
  end

  return {
    entries = count,
    oldest = oldest and os.date('%Y-%m-%d %H:%M:%S', oldest) or 'N/A',
    newest = newest and os.date('%Y-%m-%d %H:%M:%S', newest) or 'N/A'
  }
end

return M
