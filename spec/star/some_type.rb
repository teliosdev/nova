class SomeType < Nova::Star
  star_type :some_type

  metadata do
    require_options :hello
  end

  feature :some_feature do
    on :some_event do; end

    on :enable do
      tag :enable

      3
    end

    on :disable do
      tag :disable

      4
    end
  end

  on :foo do; 1; end

  on :bar, requires: :an_option do; 2; end
end
