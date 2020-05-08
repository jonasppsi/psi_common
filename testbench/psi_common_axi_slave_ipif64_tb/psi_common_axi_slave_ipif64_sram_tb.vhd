------------------------------------------------------------
-- Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
-- All rights reserved.
------------------------------------------------------------

------------------------------------------------------------
-- Testbench generated by TbGen.py
------------------------------------------------------------
-- see Library/Python/TbGenerator

-- NOTE: The testbench is not very detailed since the code tested
--       is legacy code that worked on hardware for years and hence
--       functionality seems to be generally correct.

------------------------------------------------------------
-- Libraries
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.psi_common_array_pkg.all;
use work.psi_common_math_pkg.all;
use work.psi_common_logic_pkg.all;

library work;
use work.psi_tb_txt_util.all;
use work.psi_tb_compare_pkg.all;
use work.psi_tb_activity_pkg.all;
use work.psi_tb_axi_pkg.all;

------------------------------------------------------------
-- Entity Declaration
------------------------------------------------------------
entity psi_common_axi_slave_ipif64_sram_tb is
  generic(
    UseMem_g        : boolean := true;
    AxiThrottling_g : natural := 3
  );
end entity psi_common_axi_slave_ipif64_sram_tb;

------------------------------------------------------------
-- Architecture
------------------------------------------------------------
architecture sim of psi_common_axi_slave_ipif64_sram_tb is
  -- *** Fixed Generics ***
  constant ResetVal_g : t_aslv64 := (X"0001A123B123C123", X"0002123456789ABC");

  -- *** Not Assigned Generics (default values) ***
  constant NumRegWidth_g  : integer range 1 to 8 := 5; --5(32),...,8(256)
  constant NumReg_g       : integer              := 2**NumRegWidth_g;
  constant AxiIdWidth_g   : integer              := 1;
  constant AxiAddrWidth_g : integer              := 20;
  --constant AxiAddrWidth_g : integer := NumRegWidth_g+3+2; (64bit reg => 64x8=256-> 9bit)           --GHDL CRASH

  -------------------------------------------------------------------------
  -- AXI Definition
  -------------------------------------------------------------------------
  constant ID_WIDTH   : integer := AxiIdWidth_g;
  constant ADDR_WIDTH : integer := AxiAddrWidth_g;
  constant USER_WIDTH : integer := 1;
  constant DATA_WIDTH : integer := 64;
  constant BYTE_WIDTH : integer := DATA_WIDTH / 8;

  subtype ID_RANGE is natural range ID_WIDTH - 1 downto 0;
  subtype ADDR_RANGE is natural range ADDR_WIDTH - 1 downto 0;
  subtype USER_RANGE is natural range USER_WIDTH - 1 downto 0;
  subtype DATA_RANGE is natural range DATA_WIDTH - 1 downto 0;
  subtype BYTE_RANGE is natural range BYTE_WIDTH - 1 downto 0;

  signal axi_ms : axi_ms_r(arid(ID_RANGE), awid(ID_RANGE),
                           araddr(ADDR_RANGE), awaddr(ADDR_RANGE),
                           aruser(USER_RANGE), awuser(USER_RANGE), wuser(USER_RANGE),
                           wdata(DATA_RANGE),
                           wstrb(BYTE_RANGE));

  signal axi_sm : axi_sm_r(rid(ID_RANGE), bid(ID_RANGE),
                           ruser(USER_RANGE), buser(USER_RANGE),
                           rdata(DATA_RANGE));

  -- *** TB Control ***
  signal TbRunning            : boolean                  := True;
  signal NextCase             : integer                  := -1;
  signal ProcessDone          : std_logic_vector(0 to 1) := (others => '0');
  constant AllProcessesDone_c : std_logic_vector(0 to 1) := (others => '1');
  constant TbProcNr_axi_c     : integer                  := 0;
  constant TbProcNr_ip_c      : integer                  := 1;
  signal TestCase             : integer                  := -1;
  signal CaseDone             : integer                  := -1;

  -- *** DUT Signals ***
  signal s_axi_aclk    : std_logic                                     := '1';
  signal s_axi_aresetn : std_logic                                     := '0';
  signal o_reg_rd      : std_logic_vector(NumReg_g - 1 downto 0)       := (others => '0');
  signal i_reg_rdata   : t_aslv64(0 to NumReg_g - 1)                   := (others => (others => '0'));
  signal o_reg_wr      : std_logic_vector(NumReg_g - 1 downto 0)       := (others => '0');
  signal o_reg_wdata   : t_aslv64(0 to NumReg_g - 1)                   := (others => (others => '0'));
  signal o_mem_addr    : std_logic_vector(AxiAddrWidth_g - 1 downto 0) := (others => '0');
  signal o_mem_wr      : std_logic_vector(BYTE_WIDTH - 1 downto 0)     := (others => '0');
  signal o_mem_wdata   : std_logic_vector(DATA_WIDTH - 1 downto 0)     := (others => '0');
  signal i_mem_rdata   : std_logic_vector(DATA_WIDTH - 1 downto 0)     := (others => '0');

  procedure WaitCase(nr : integer) is
  begin
    while TestCase /= nr loop
      wait until rising_edge(s_axi_aclk);
    end loop;
  end procedure;

  procedure WaitDone(nr : integer) is
  begin
    while CaseDone /= nr loop
      wait until rising_edge(s_axi_aclk);
    end loop;
  end procedure;

begin
  ------------------------------------------------------------
  -- DUT Instantiation
  ------------------------------------------------------------
  i_dut : entity work.psi_common_axi_slave_ipif64
    generic map(
      NumReg_g       => NumReg_g,
      UseMem_g       => UseMem_g,
      ResetVal_g     => ResetVal_g,
      --
      AxiIdWidth_g   => 1,
      AxiAddrWidth_g => AxiAddrWidth_g,
      AxiDataWidth_g => DATA_WIDTH,
      AxiByteWidth_g => BYTE_WIDTH
    )
    port map(
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_arid    => axi_ms.arid,
      s_axi_araddr  => axi_ms.araddr,
      s_axi_arlen   => axi_ms.arlen,
      s_axi_arsize  => axi_ms.arsize,
      s_axi_arburst => axi_ms.arburst,
      s_axi_arlock  => axi_ms.arlock,
      s_axi_arcache => axi_ms.arcache,
      s_axi_arprot  => axi_ms.arprot,
      s_axi_arvalid => axi_ms.arvalid,
      s_axi_arready => axi_sm.arready,
      s_axi_rid     => axi_sm.rid,
      s_axi_rdata   => axi_sm.rdata,
      s_axi_rresp   => axi_sm.rresp,
      s_axi_rlast   => axi_sm.rlast,
      s_axi_rvalid  => axi_sm.rvalid,
      s_axi_rready  => axi_ms.rready,
      s_axi_awid    => axi_ms.awid,
      s_axi_awaddr  => axi_ms.awaddr,
      s_axi_awlen   => axi_ms.awlen,
      s_axi_awsize  => axi_ms.awsize,
      s_axi_awburst => axi_ms.awburst,
      s_axi_awlock  => axi_ms.awlock,
      s_axi_awcache => axi_ms.awcache,
      s_axi_awprot  => axi_ms.awprot,
      s_axi_awvalid => axi_ms.awvalid,
      s_axi_awready => axi_sm.awready,
      s_axi_wdata   => axi_ms.wdata,
      s_axi_wstrb   => axi_ms.wstrb,
      s_axi_wlast   => axi_ms.wlast,
      s_axi_wvalid  => axi_ms.wvalid,
      s_axi_wready  => axi_sm.wready,
      s_axi_bid     => axi_sm.bid,
      s_axi_bresp   => axi_sm.bresp,
      s_axi_bvalid  => axi_sm.bvalid,
      s_axi_bready  => axi_ms.bready,
      o_reg_rd      => o_reg_rd,
      i_reg_rdata   => i_reg_rdata,
      o_reg_wr      => o_reg_wr,
      o_reg_wdata   => o_reg_wdata,
      o_mem_addr    => o_mem_addr,
      o_mem_wr      => o_mem_wr,
      o_mem_wdata   => o_mem_wdata,
      i_mem_rdata   => i_mem_rdata
    );

  gen_dut_sram_block_g : for k in 0 to BYTE_WIDTH - 1 generate --k identifies the bit position of the strobe
    i_dut_sram : entity work.psi_common_sdp_ram
      generic map(
        Depth_g    => 2**(AxiAddrWidth_g - 3),
        Width_g    => DATA_WIDTH / 8,
        IsAsync_g  => false,
        RamStyle_g => "auto",
        Behavior_g => "RBW"
      )
      port map(
        -- Control Signals
        Clk    => s_axi_aclk,
        RdClk  => s_axi_aclk,
        -- Write Port
        WrAddr => o_mem_addr(o_mem_addr'length - 1 downto 3),
        Wr     => o_mem_wr(k),
        WrData => o_mem_wdata((k + 1) * 8 - 1 downto k * 8),
        -- Read Port
        RdAddr => o_mem_addr(o_mem_addr'length - 1 downto 3),
        Rd     => '1',
        RdData => i_mem_rdata((k + 1) * 8 - 1 downto k * 8)
      );
  end generate gen_dut_sram_block_g;

  ------------------------------------------------------------
  -- Testbench Control !DO NOT EDIT!
  ------------------------------------------------------------
  p_tb_control : process
  begin
    wait until s_axi_aresetn = '1';
    wait until ProcessDone = AllProcessesDone_c;
    TbRunning <= false;
    wait;
  end process;

  ------------------------------------------------------------
  -- Clocks !DO NOT EDIT!
  ------------------------------------------------------------
  p_clock_s_axi_aclk : process
    constant Frequency_c : real := real(100e6);
  begin
    while TbRunning loop
      wait for 0.5 * (1 sec) / Frequency_c;
      s_axi_aclk <= not s_axi_aclk;
    end loop;
    wait;
  end process;

  ------------------------------------------------------------
  -- Resets
  ------------------------------------------------------------
  p_rst_s_axi_aresetn : process
  begin
    wait for 1 us;
    -- Wait for two clk edges to ensure reset is active for at least one edge
    wait until rising_edge(s_axi_aclk);
    wait until rising_edge(s_axi_aclk);
    s_axi_aresetn <= '1';
    wait;
  end process;

  ------------------------------------------------------------
  -- Processes
  ------------------------------------------------------------
  -- *** axi ***
  p_axi : process
  begin
    axi_master_init(axi_ms);

    -- start of process !DO NOT EDIT
    wait until s_axi_aresetn = '1';

    -- *** Test Reset Behavior ***
    print(">> Reset Behavior");
    TestCase <= 0;
    WaitDone(0);

    -- *** Test Single Read/Write to Registers ***
    if NumReg_g > 0 then
      print(">> Single Read/Write to Registers");
      TestCase <= 1;
      -- write
      axi_single_write(8 * 1, "0123456789ABCDEF", 16, axi_ms, axi_sm, s_axi_aclk);
      -- read
      axi_single_expect(8 * 1, "6666555577778888", 16, axi_ms, axi_sm, s_axi_aclk, "No Msg", 63, 0, false, 0);
      WaitDone(1);
    end if;

    -- *** Test Single Read/Write to Memory ***
    print(">> Single Read/Write to Memory");
    TestCase <= 2;
    if UseMem_g then
      -- write
      axi_single_write(8 * (NumReg_g + 1), "1122334455667788", 16, axi_ms, axi_sm, s_axi_aclk);
      -- read
      axi_single_expect(8 * (NumReg_g + 1), "1122334455667788", 16, axi_ms, axi_sm, s_axi_aclk, "No Msg", 63, 0, false, 0);
    else
      -- write
      axi_apply_aw(8 * (NumReg_g + 1), AxSIZE_8_c, 1 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
      axi_apply_wd_single(X"ABCD12340000FFFF", X"FF", axi_ms, axi_sm, s_axi_aclk);
      axi_expect_bresp(xRESP_DECERR_c, axi_ms, axi_sm, s_axi_aclk);
      -- read 
      axi_apply_ar(8 * (NumReg_g + 1), AxSIZE_8_c, 1 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
      axi_expect_rresp_single(X"0000000000000000", xRESP_DECERR_c, axi_ms, axi_sm, s_axi_aclk, IgnoreData => true);
    end if;
    WaitDone(2);

    -- *** Test Burst Read/Write to Registers ***
    if NumReg_g > 0 then
      print(">> Burst Read/Write to Registers");
      TestCase <= 3;
      -- write
      axi_apply_aw(8 * 1, AxSIZE_8_c, 3 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
      axi_apply_wd_burst(3, "100000007ffffff1", "A", 16, "11111111", "11111111", axi_ms, axi_sm, s_axi_aclk, AxiThrottling_g);
      axi_expect_bresp(xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk);
      -- read
      axi_apply_ar(8 * 1, AxSIZE_8_c, 3 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
      axi_expect_rresp_burst(3, "1000000000000100", "1", 16, xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk, false, false, AxiThrottling_g);
      WaitDone(3);
    end if;

    -- *** Test Burst Read/Write to all Registers ***
    if NumReg_g > 0 then
      print(">> Burst Read/Write to all Registers");
      TestCase <= 4;
      -- write
      axi_apply_aw(0, AxSIZE_8_c, NumReg_g - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
      axi_apply_wd_burst(NumReg_g, "100000007ffffff1", "A", 16, "11111111", "11111111", axi_ms, axi_sm, s_axi_aclk, AxiThrottling_g);
      axi_expect_bresp(xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk);
      -- read
      axi_apply_ar(0, AxSIZE_8_c, NumReg_g - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
      axi_expect_rresp_burst(NumReg_g, "1000000000001000", "1", 16, xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk, false, false, AxiThrottling_g);
      WaitDone(4);
    end if;

    -- *** Test Burst Read/Write to Memory ***		
    print(">> Burst Read/Write to Memory");
    TestCase <= 5;
    -- write
    axi_apply_aw(8 * (NumReg_g), AxSIZE_8_c, 4 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
    axi_apply_wd_burst(4, "1000000000000200", "1", 16, "11111111", "10000111", axi_ms, axi_sm, s_axi_aclk, AxiThrottling_g);
    if UseMem_g then
      axi_expect_bresp(xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk);
    else
      -- Expect error if memory interface is not implemented
      axi_expect_bresp(xRESP_DECERR_c, axi_ms, axi_sm, s_axi_aclk);
    end if;
    -- read
    axi_apply_ar(8 * (NumReg_g), AxSIZE_8_c, 4 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk); --Addr=NumReg_g+2 -> ExpData==0x302
    if UseMem_g then
      axi_expect_rresp_burst(4, "1000000000000200", "1", 16, xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk, false, false, AxiThrottling_g);
    else
      axi_expect_rresp_burst(4, "1000000000000200", "1", 16, xRESP_DECERR_c, axi_ms, axi_sm, s_axi_aclk, true, false, AxiThrottling_g);
    end if;
    WaitDone(5);

    -- *** Test Burst over Reg/Mem Boundary***
    print(">> Burst over Reg/Mem Boundary");
    TestCase <= 6;
    -- write
    axi_apply_aw(8 * (NumReg_g - 2), AxSIZE_8_c, 256 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
    axi_apply_wd_burst(256, "1000000000000400", "1", 16, "11111111", "11111111", axi_ms, axi_sm, s_axi_aclk, AxiThrottling_g);
    if UseMem_g then
      axi_expect_bresp(xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk);
    else
      -- Expect error if memory interface is not implemented
      axi_expect_bresp(xRESP_DECERR_c, axi_ms, axi_sm, s_axi_aclk);
    end if;
    -- read
    axi_apply_ar(8 * (NumReg_g - 2), AxSIZE_8_c, 256 - 1, xBURST_INCR_c, axi_ms, axi_sm, s_axi_aclk);
    if UseMem_g then
      axi_expect_rresp_burst(256, "1000000000000400", "1", 16, xRESP_OKAY_c, axi_ms, axi_sm, s_axi_aclk, false, false, AxiThrottling_g);
    else
      axi_expect_rresp_burst(256, "1000000000000400", "1", 16, xRESP_DECERR_c, axi_ms, axi_sm, s_axi_aclk, true, false, AxiThrottling_g);
    end if;
    WaitDone(6);

    -- end of process !DO NOT EDIT!
    ProcessDone(TbProcNr_axi_c) <= '1';
    wait;
  end process;

  -- *** ip ***
  p_ip : process
    variable StartTime_v : time;
    variable RecWords_v  : std_logic_vector(3 downto 0);
    variable MemWord_v   : integer;
    variable ExpData_v   : signed(axi_ms.wdata'length - 1 downto 0);
    variable RegData_v   : unsigned(axi_ms.wdata'length - 1 downto 0);
    variable MemData_v   : unsigned(axi_ms.wdata'length - 1 downto 0);
  begin
    -- start of process !DO NOT EDIT
    wait until s_axi_aresetn = '1';

    -- *** Test Reset Behavior ***		
    WaitCase(0);
    if NumReg_g > 0 then
      StdlvCompareStdlv(X"0001A123B123C123", o_reg_wdata(0), "Wrong reset data [0]");
      StdlvCompareStdlv(X"0002123456789ABC", o_reg_wdata(1), "Wrong reset data [1]");
      StdlvCompareStdlv(X"0000000000000000", o_reg_wdata(2), "Wrong reset data [2]");
      StdlvCompareStdlv(X"0000000000000000", o_reg_wdata(3), "Wrong reset data [3]");
    end if;
    if UseMem_g then
      StdlvCompareStdlv("00000000", o_mem_wr, "Wrong reset o_mem_wr");
    end if;
    CaseDone <= 0;

    -- *** Test Single Read/Write to Registers ***
    if NumReg_g > 0 then
      WaitCase(1);
      i_reg_rdata(1) <= X"6666555577778888";
      WaitForValueStdl(o_reg_wr(1), '1', 1 us, "Write did not arrive");
      StdlvCompareStdlv(X"0123456789ABCDEF", o_reg_wdata(1), "Wrong reset data [1]");
      WaitForValueStdl(o_reg_rd(1), '1', 1 us, "Read did not arrive");
      CaseDone       <= 1;
    end if;

    -- *** Test Single Read/Write to Memory ***		
    WaitCase(2);
    -- Write
    if UseMem_g then
      wait until rising_edge(s_axi_aclk) and o_mem_wr = "11111111" for 1 us;
      StdlvCompareStdlv("11111111", o_mem_wr, "Write did not arrive");
      StdlvCompareStdlv(X"1122334455667788", o_mem_wdata, "Received wrong data");
      StdlvCompareInt(1 * 8, o_mem_addr, "Wrong write address");
    end if;
    -- Read (not needed becuase we are using the SRAM)
    CaseDone <= 2;

    -- *** Test Burst Read/Write to Registers ***
    if NumReg_g > 0 then
      WaitCase(3);
      i_reg_rdata(1) <= X"1000000000000100";
      i_reg_rdata(2) <= X"1000000000000101";
      i_reg_rdata(3) <= X"1000000000000102";
      ExpData_v      := hex_string_to_signed("100000007ffffff1", ExpData_v'length);
      for i in 1 to 3 loop
        wait until rising_edge(s_axi_aclk) and o_reg_wr(i) = '1' for 1 us;
        StdlCompare(1, o_reg_wr(i), "Write did not arrive");
        StdlvCompareStdlv(std_logic_vector(ExpData_v), o_reg_wdata(i), "Wrong write data");
        ExpData_v := ExpData_v + 16#A#;
      end loop;
      CaseDone       <= 3;
    end if;

    -- *** Test Burst Read/Write to all Registers ***
    if NumReg_g > 0 then
      WaitCase(4);
      RegData_v := hex_string_to_unsigned("1000000000001000", RegData_v'length);
      for i in 0 to NumReg_g - 1 loop
        --i_reg_rdata(i) <= std_logic_vector(to_unsigned(16#00001000#+i, 64));
        i_reg_rdata(i) <= std_logic_vector(RegData_v);
        RegData_v      := RegData_v + 1;
      end loop;
      ExpData_v := hex_string_to_signed("100000007ffffff1", ExpData_v'length);
      for i in 0 to NumReg_g - 1 loop
        wait until rising_edge(s_axi_aclk) and o_reg_wr(i) = '1' for 1 us;
        StdlCompare(1, o_reg_wr(i), "Write did not arrive");
        StdlvCompareStdlv(std_logic_vector(ExpData_v), o_reg_wdata(i), "Wrong write data");
        ExpData_v := ExpData_v + 16#A#;
      end loop;
      CaseDone  <= 4;
    end if;

    -- *** Test Burst Read/Write to Memory ***		
    WaitCase(5);
    -- Write
    if UseMem_g then
      wait until rising_edge(s_axi_aclk) and o_mem_wr /= "00000000" for 1 us;
      StdlvCompareStdlv("11111111", o_mem_wr, "o_mem_wr[0] wrong");
      StdlvCompareStdlv(X"1000000000000200", o_mem_wdata, "o_mem_wdata[0] wrong");
      wait until rising_edge(s_axi_aclk) and o_mem_wr /= "00000000" for 1 us;
      StdlvCompareStdlv("11111111", o_mem_wr, "o_mem_wr[1] wrong");
      StdlvCompareStdlv(X"1000000000000201", o_mem_wdata, "o_mem_wdata[1] wrong");
      wait until rising_edge(s_axi_aclk) and o_mem_wr /= "00000000" for 1 us;
      StdlvCompareStdlv("11111111", o_mem_wr, "o_mem_wr[2] wrong");
      StdlvCompareStdlv(X"1000000000000202", o_mem_wdata, "o_mem_wdata[2] wrong");
      wait until rising_edge(s_axi_aclk) and o_mem_wr /= "00000000" for 1 us;
      StdlvCompareStdlv("10000111", o_mem_wr, "o_mem_wr[3] wrong");
      StdlvCompareStdlv(X"1000000000000203", o_mem_wdata, "o_mem_wdata[3] wrong");
    end if;
    -- Read (not needed becuase we are using the SRAM)
    CaseDone <= 5;

    -- *** Test Burst over Reg/Mem Boundary***
    WaitCase(6);
    -- write (check each word in parallel since accesses to registers/memory have different timing and can happen at the same time)
    if UseMem_g then
      RecWords_v := (others => '0');
      MemWord_v  := 0;
      while RecWords_v(3 downto 0) /= "1111" loop
        wait until rising_edge(s_axi_aclk);
        if o_reg_wr(NumReg_g - 2) = '1' then
          StdlvCompareStdlv(X"1000000000000400", o_reg_wdata(NumReg_g - 2), "Wrong reset data[0]");
          RecWords_v(0) := '1';
        end if;
        if o_reg_wr(NumReg_g - 1) = '1' then
          StdlvCompareStdlv(X"1000000000000401", o_reg_wdata(NumReg_g - 1), "Wrong reset data[1]");
          RecWords_v(1) := '1';
        end if;
        if o_mem_wr /= "00000000" then
          StdlvCompareStdlv("11111111", o_mem_wr, "o_mem_wr wrong");
          SignCompare2(Expected => hex_string_to_signed("1000000000000402", o_mem_wdata'length) + MemWord_v, --: in signed;
                       Actual   => signed(o_mem_wdata), --: in signed;
                       Msg      => "SignCompare2: " --:  in string;
                      );
          RecWords_v(2 + MemWord_v) := '1';
          MemWord_v                 := MemWord_v + 1;
        end if;
      end loop;
    end if;
    -- read
    if UseMem_g then
      i_reg_rdata(NumReg_g - 2) <= X"1000000000000400";
      i_reg_rdata(NumReg_g - 1) <= X"1000000000000401";
      RecWords_v                := (others => '0');
      -- Memory Read (not needed becuase we are using the SRAM)
    end if;
    CaseDone <= 6;

    -- end of process !DO NOT EDIT!
    ProcessDone(TbProcNr_ip_c) <= '1';
    wait;
  end process;

end;