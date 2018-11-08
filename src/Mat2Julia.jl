module Mat2Julia

function speed()
    r = rand(100000)
    @time speed_test(r)
end

function speed_test(r)
    for k = 1:99
        Mat2Julia.medfilt1(r[k*1000 .+ (1:1000)], 14)
    end
end

function medfilt1(arr_raw, filt_len)
    arr = [zeros(eltype(arr_raw), ceil(Int, (filt_len-1) / 2)); arr_raw; zeros(eltype(arr_raw), floor(Int, (filt_len-1) / 2))]

    arr_len = length(arr)
    filt_len_odd = isodd(filt_len)
    half_ind = ceil(Int, filt_len / 2)
    meds = zeros(arr_len - filt_len + 1)
    list = arr[1:filt_len]
    order = sortperm(list)
    new_order = order
    if filt_len_odd
        meds[1] = list[order[half_ind]]
    else
        meds[1] = (list[order[half_ind]] + list[order[half_ind + 1]]) / 2
    end

    counter = 1 # track which element to swap out next
    for k = filt_len+1:arr_len
        list[counter] = arr[k] # swap out oldest element

        ind = 1
        placed = false
        for n = 1:filt_len

            if order[n] == counter || ind >= filt_len
                continue # do nothing
            elseif list[order[n]] > list[counter] && ~placed
                placed = true
                new_order[ind] = counter
                ind += 1
            end
            new_order[ind] = order[n]
            ind += 1
        end
        if ~placed
            new_order[ind] = counter
        end
        order = copy(new_order)

        if filt_len_odd > 0
            median_k = list[order[half_ind]]
        else
            median_k = (list[order[half_ind]] + list[order[half_ind + 1]]) / 2
        end
        meds[k - filt_len + 1] = median_k

        counter = mod1(counter + 1, filt_len)
    end

    return meds
end

function conv(u, v, shape::String="")
      m = length(u)
      n = length(v)
      p = m + n - 1
      w = zeros(p)

      for j = 1:m
          for k =j:j + n - 1
              w[k] += u[j] * v[k - j + 1]
          end
      end

      shape == "valid" && return w[n:m]
      q = (n - 1) / 2
      shape == "same" && return w[1 + floor(Int, q):n+m-1-ceil(Int, q)]
      return w
 end

function flip(x)
    return x[end:-1:1]
end

function median(x, opt::String="")
    y = opt == "omitnan" ? filter(!isnan, x) : x
    sort!(y)
    len = length(y)
    if isodd(len)
        return y[div(len + 1, 2)]
    else
        return (y[div(len, 2)] + y[div(len, 2) + 1]) / 2
    end
end

function mean(x, opt::String="")
    y = opt == "omitnan" ? filter(!isnan, x) : x
    return sum(y) / length(y)
end

end # module
