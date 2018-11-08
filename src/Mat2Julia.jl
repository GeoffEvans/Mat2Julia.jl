module Mat2Julia

function medfilt1(arr, filt_len)
    arr_len = length(arr)
    filt_len_odd = isodd(filt_len)
    half_ind = ceil(Int, filt_len / 2)
    meds = zeros(arr_len - filt_len + 1)
    list = arr[1:filt_len]
    order = sortperm(list)
    if filt_len_odd > 0
        meds[1] = list[order[half_ind]]
    else
        meds[1] = (list[order[half_ind]] + list[order[half_ind + 1]]) / 2
    end

    counter = 1 # track which element to swap out next
    for k = filt_len+1:arr_len
        list[counter] = arr[k] # swap out oldest element

        m = findfirst(order .== counter) # old element position in order
        n = count(list[counter] .>= list) # new element position in order, use self equality in comparison
        if m < n
            order[m:n-1] = order[m+1:n] # downshift
        else
            order[n+1:m] = order[n:m-1] # upshift
        end
        order[n] = counter

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
