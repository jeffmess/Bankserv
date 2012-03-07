module Helpers
  def tear_it_down
    Bankserv::Configuration.delete_all
    Bankserv::Request.delete_all
  
    Bankserv::BankAccount.delete_all
    Bankserv::AccountHolderVerification.delete_all
    Bankserv::Debit.delete_all
    Bankserv::Credit.delete_all
    
    Bankserv::Document.delete_all
    Bankserv::Set.delete_all
    Bankserv::Record.delete_all
    
    Bankserv::Statement.delete_all
    Bankserv::Transaction.delete_all
  end
  
  def create_credit_request
    credit = Bankserv::Credit.request({
      type: 'credit',
      data: {
        type_of_service: "BATCH",
        accepted_report: "Y",
        account_type_correct: "Y",
        batches: [{
          debit: {
            account_number: "4068123456", branch_code: "632005", account_type: '1', id_number: '8207205263083', initials: "RC", account_name: "TESTTEST", amount: 1272216.65, user_ref: "CONTRA_0000846_PMT", action_date: Date.today
          },
          credit: [
            { account_number: '00081136250', branch_code: '050021', account_type: "1",  amount:  "000015000.00", action_date: Date.today, account_name: "DEWEY  ASSOCIATES",             user_ref: "_2055185_PAY USER"},
            { account_number: '04051717311', branch_code: '632005', account_type: "1",  amount:  "000005423.80", action_date: Date.today, account_name: "SURE SLIM WELLNESS CLINIC SA",  user_ref: "_2055184_PAY USER"},
            { account_number: '09193079313', branch_code: '632005', account_type: "1",  amount:  "000002245.00", action_date: Date.today, account_name: "RUGGA KIDS EAST RAND",          user_ref: "_2055183_PAY USER"},
            { account_number: '01028268041', branch_code: '102809', account_type: "1",  amount:  "000001140.00", action_date: Date.today, account_name: "RUGGA KIDS", user_ref: "_2055182_PAY USER"},
            { account_number: '62162065752', branch_code: '250655', account_type: "1",  amount:  "000000840.00", action_date: Date.today, account_name: "RUGGA KIDS WEST RAND", user_ref: "_2055181_PAY USER"},
            { account_number: '62181078166', branch_code: '222026', account_type: "1",  amount:  "000002485.88", action_date: Date.today, account_name: "MENLYN PAYROLL ADMINISTRATION", user_ref: "_2055180_PAY USER"},
            { account_number: '00011986778', branch_code: '051001', account_type: "1",  amount:  "000000460.00", action_date: Date.today, account_name: "SPUTNIC FINANSIELE ADVISEURS", user_ref: "_2055179_PAY USER"},
            { account_number: '00001970534', branch_code: '051001', account_type: "1",  amount:  "000004246.50", action_date: Date.today, account_name: "AMG", user_ref: "_2055178_PAY USER"},
            { account_number: '04063350931', branch_code: '632005', account_type: "1",  amount:  "000001750.00", action_date: Date.today, account_name: "CHEMC PUBLISHERS", user_ref: "_2055177_PAY USER"},
            { account_number: '62099422190', branch_code: '250655', account_type: "1",  amount:  "000002882.70", action_date: Date.today, account_name: "AMUCUS MAKELAARS", user_ref: "_2055176_PAY USER"},
            { account_number: '00012784141', branch_code: '051001', account_type: "1",  amount:  "000000150.00", action_date: Date.today, account_name: "DYNAMIC FINANCIAL SOLUTIONS", user_ref: "_2055175_PAY USER"},
            { account_number: '62070310843', branch_code: '250655', account_type: "1",  amount:  "000001790.00", action_date: Date.today, account_name: "PAYROLL MASTERS", user_ref: "_2055174_PAY USER"},
            { account_number: '01220161923', branch_code: '632005', account_type: "1",  amount:  "000003663.00", action_date: Date.today, account_name: "JCJ ROBBERTZE  VENNOTE", user_ref: "_2055173_PAY USER"},
            { account_number: '00000160180', branch_code: '051001', account_type: "1",  amount:  "000011506.03", action_date: Date.today, account_name: "D BETE FINANCIALS", user_ref: "_2055172_PAY USER"},
            { account_number: '62095194751', branch_code: '250545', account_type: "1",  amount:  "000012692.80", action_date: Date.today, account_name: "THUKELA METERING CC", user_ref: "_2055171_PAY USER"},
            { account_number: '04071395890', branch_code: '632005', account_type: "1",  amount:  "000004950.00", action_date: Date.today, account_name: "EAST LONDON SELF STORAGE", user_ref: "_2055170_PAY USER"},
            { account_number: '00071105301', branch_code: '051001', account_type: "1",  amount:  "000010300.00", action_date: Date.today, account_name: "EMA CAPE TOWN", user_ref: "_2055169_PAY USER"},
            { account_number: '52100657520', branch_code: '260449', account_type: "1",  amount:  "000002880.00", action_date: Date.today, account_name: "DUIWELSKLOOF LAERSKOOL", user_ref: "_2055168_PAY USER"},
            { account_number: '62054634128', branch_code: '251345', account_type: "1",  amount:  "000001182.69", action_date: Date.today, account_name: "DANVILLE HULP PROJEK", user_ref: "_2055167_PAY USER"},
            { account_number: '09103104540', branch_code: '632005', account_type: "1",  amount:  "000002000.00", action_date: Date.today, account_name: "ACADEMY OF ADVANCED TECHNOLOG", user_ref: "_2055166_PAY USER"},
            { account_number: '62028250570', branch_code: '254005', account_type: "1",  amount:  "000009672.07", action_date: Date.today, account_name: "MOTION TELECOMMUNICATIONS", user_ref: "_2055165_PAY USER"},
            { account_number: '01930012810', branch_code: '193042', account_type: "1",  amount:  "000051657.27", action_date: Date.today, account_name: "JS INVESTMENTS T/A RENTA SHA", user_ref: "_2055164_PAY USER"},
            { account_number: '04052569658', branch_code: '632005', account_type: "1",  amount:  "000001040.00", action_date: Date.today, account_name: "SCUBAVERSITY", user_ref: "_2055163_PAY USER"},
            { account_number: '00011948787', branch_code: '011545', account_type: "1",  amount:  "000016809.00", action_date: Date.today, account_name: "INFOFX", user_ref: "_2055162_PAY USER"},
            { account_number: '00080017436', branch_code: '050017', account_type: "1",  amount:  "000000695.00", action_date: Date.today, account_name: "OLD GREYS UNION", user_ref: "_2055161_PAY USER"},
            { account_number: '00033268088', branch_code: '052551', account_type: "1",  amount:  "000001884.35", action_date: Date.today, account_name: "VAN WYK", user_ref: "_2055160_PAY USER"},
            { account_number: '04062574748', branch_code: '632005', account_type: "1",  amount:  "000002170.68", action_date: Date.today, account_name: "GARYP T/A PICTURE PERFECT", user_ref: "_2055159_PAY USER"},
            { account_number: '01602339775', branch_code: '160245', account_type: "1",  amount:  "000026390.22", action_date: Date.today, account_name: "G ERASMUS REKENKUNDIGE DIENST", user_ref: "_2055158_PAY USER"},
            { account_number: '00411345060', branch_code: '051001', account_type: "1",  amount:  "000008233.65", action_date: Date.today, account_name: "PICTURE PERFECT HATFIELD", user_ref: "_2055157_PAY USER"},
            { account_number: '00421498757', branch_code: '009953', account_type: "1",  amount:  "000003520.00", action_date: Date.today, account_name: "RUGGA KIDS SA PTY LTD", user_ref: "_2055156_PAY USER"},
            { account_number: '00033165599', branch_code: '052546', account_type: "1",  amount:  "000007920.00", action_date: Date.today, account_name: "RUGGA KIDS PRETORIA", user_ref: "_2055155_PAY USER"},
            { account_number: '00023355743', branch_code: '051001', account_type: "1",  amount:  "000002340.00", action_date: Date.today, account_name: "RUGGA KIDS SA PTY LTD", user_ref: "_2055154_PAY USER"},
            { account_number: '09075905022', branch_code: '516805', account_type: "1",  amount:  "000009216.17", action_date: Date.today, account_name: "EXCELL ACCOUNTING SERVICES", user_ref: "_2055153_PAY USER"},
            { account_number: '01419089617', branch_code: '141949', account_type: "1",  amount:  "000001459.00", action_date: Date.today, account_name: "EXCELLENT HOMEWARE", user_ref: "_2055152_PAY USER"},
            { account_number: '00032985258', branch_code: '051001', account_type: "1",  amount:  "000007759.62", action_date: Date.today, account_name: "LARIAT TECHNOLOGIES", user_ref: "_2055151_PAY USER"},
            { account_number: '01003360675', branch_code: '632005', account_type: "1",  amount:  "000016575.00", action_date: Date.today, account_name: "IAASA", user_ref: "_2055150_PAY USER"},
            { account_number: '00200123475', branch_code: '006305', account_type: "1",  amount:  "000034701.60", action_date: Date.today, account_name: "CCF  ASSOCIATES", user_ref: "_2055149_PAY USER"},
            { account_number: '09097479936', branch_code: '632005', account_type: "1",  amount:  "000004680.00", action_date: Date.today, account_name: "SEEDCAP PTY LTD", user_ref: "_2055148_PAY USER"},
            { account_number: '62092576027', branch_code: '220526', account_type: "1",  amount:  "000025052.00", action_date: Date.today, account_name: "PICTURE PERFECT DUBAN", user_ref: "_2055147_PAY USER"},
            { account_number: '00628303343', branch_code: '051001', account_type: "1",  amount:  "000003345.00", action_date: Date.today, account_name: "FAERIE GLEN SELF STORAGE", user_ref: "_2055146_PAY USER"},
            { account_number: '04053302079', branch_code: '632005', account_type: "1",  amount:  "000013450.00", action_date: Date.today, account_name: "BULLIVANT ACCOUNTING  TAX SER", user_ref: "_2055145_PAY USER"},
            { account_number: '01063871270', branch_code: '632005', account_type: "1",  amount:  "000021600.00", action_date: Date.today, account_name: "TIENERS IN CHRISTUS", user_ref: "_2055144_PAY USER"},
            { account_number: '04049418620', branch_code: '632005', account_type: "1",  amount:  "000008575.21", action_date: Date.today, account_name: "INTEGRITAS OUDITEURE", user_ref: "_2055143_PAY USER"},
            { account_number: '00425288536', branch_code: '051001', account_type: "1",  amount:  "000002823.00", action_date: Date.today, account_name: "POOL REPAIR CENTRE", user_ref: "_2055142_PAY USER"},
            { account_number: '01026001439', branch_code: '102642', account_type: "1",  amount:  "000011480.00", action_date: Date.today, account_name: "MANDRE EIENDOMS TRUST", user_ref: "_2055141_PAY USER"},
            { account_number: '04058643395', branch_code: '632005', account_type: "1",  amount:  "000001840.94", action_date: Date.today, account_name: "WESSEL SMALBERGER", user_ref: "_2055140_PAY USER"},
            { account_number: '00010242886', branch_code: '632005', account_type: "1",  amount:  "000003563.40", action_date: Date.today, account_name: "EAST RAND DOCUMENTS SOLUTIONS", user_ref: "_2055139_PAY USER"},
            { account_number: '04058021573', branch_code: '632005', account_type: "1",  amount:  "000014674.66", action_date: Date.today, account_name: "PICTURE PERFECT", user_ref: "_2055138_PAY USER"},
            { account_number: '00071093664', branch_code: '051001', account_type: "1",  amount:  "000002100.00", action_date: Date.today, account_name: "EMA KIDS FOUNDATION", user_ref: "_2055137_PAY USER"},
            { account_number: '04052805995', branch_code: '632005', account_type: "1",  amount:  "000009070.00", action_date: Date.today, account_name: "BIZ AFRICA PTY LTD VON WIEL", user_ref: "_2055136_PAY USER"},
            { account_number: '04059290222', branch_code: '535105', account_type: "1",  amount:  "000099180.70", action_date: Date.today, account_name: "SQUARE ONE CAPITAL PTY LTD", user_ref: "_2055135_PAY USER"},
            { account_number: '01910177911', branch_code: '191042', account_type: "1",  amount:  "000021475.00", action_date: Date.today, account_name: "STRYDOM PROKUREURS", user_ref: "_2055134_PAY USER"},
            { account_number: '04063058446', branch_code: '632005', account_type: "1",  amount:  "000004170.00", action_date: Date.today, account_name: "VIP BIN CLEANING MATLAND", user_ref: "_2055133_PAY USER"},
            { account_number: '01430580201', branch_code: '632005', account_type: "1",  amount:  "000019003.00", action_date: Date.today, account_name: "NED HERV KERK OOSMOOT", user_ref: "_2055132_PAY USER"},
            { account_number: '01284101932', branch_code: '128405', account_type: "1",  amount:  "000030289.80", action_date: Date.today, account_name: "PRESSED IN TIME", user_ref: "_2055131_PAY USER"},
            { account_number: '00033211736', branch_code: '051001', account_type: "1",  amount:  "000001250.00", action_date: Date.today, account_name: "LVP PROKUREURS", user_ref: "_2055130_PAY USER"},
            { account_number: '01128016583', branch_code: '112805', account_type: "1",  amount:  "000000500.00", action_date: Date.today, account_name: "THOMSON ACCOUNTANTS", user_ref: "_2055129_PAY USER"},
            { account_number: '01128016583', branch_code: '112805', account_type: "1",  amount:  "000001664.81", action_date: Date.today, account_name: "THOMSON ACCOUNTANTS", user_ref: "_2055128_PAY USER"},
            { account_number: '01128016567', branch_code: '112805', account_type: "1",  amount:  "000001529.52", action_date: Date.today, account_name: "THOMSON ACCOUNTANTS", user_ref: "_2055127_PAY USER"},
            { account_number: '00402087259', branch_code: '051001', account_type: "1",  amount:  "000001500.00", action_date: Date.today, account_name: "RUGGA KIDS SA PTY", user_ref: "_2055126_PAY USER"},
            { account_number: '04063531692', branch_code: '632005', account_type: "1",  amount:  "000003500.00", action_date: Date.today, account_name: "GAUTENG SOCIETY OF ADVOCATES", user_ref: "_2055125_PAY USER"},
            { account_number: '00033190283', branch_code: '052546', account_type: "1",  amount:  "000110220.20", action_date: Date.today, account_name: "JCM REKENMEESTERS BK", user_ref: "_2055124_PAY USER"},
            { account_number: '00420056084', branch_code: '001255', account_type: "1",  amount:  "000015812.24", action_date: Date.today, account_name: "NOESIS INC", user_ref: "_2055123_PAY USER"},
            { account_number: '04066398308', branch_code: '632005', account_type: "1",  amount:  "000015963.60", action_date: Date.today, account_name: "MSR SECURITY", user_ref: "_2055122_PAY USER"},
            { account_number: '62056207527', branch_code: '251655', account_type: "1",  amount:  "000004264.07", action_date: Date.today, account_name: "JUSTIN HOLMES REGISTERED FINA", user_ref: "_2055121_PAY USER"},
            { account_number: '01284056899', branch_code: '128405', account_type: "1",  amount:  "000002395.00", action_date: Date.today, account_name: "ATTI", user_ref: "_2055120_PAY USER"},
            { account_number: '01756006202', branch_code: '175605', account_type: "1",  amount:  "000010380.00", action_date: Date.today, account_name: "LINKSFIELD PRIMARY", user_ref: "_2055119_PAY USER"},
            { account_number: '04052669723', branch_code: '632005', account_type: "1",  amount:  "000005750.58", action_date: Date.today, account_name: "ODYSSEY SOFTWARE", user_ref: "_2055118_PAY USER"},
            { account_number: '62121300347', branch_code: '230732', account_type: "1",  amount:  "000000315.00", action_date: Date.today, account_name: "GARDEN OBSESSIONS", user_ref: "_2055117_PAY USER"},
            { account_number: '00073192759', branch_code: '051001', account_type: "1",  amount:  "000001381.00", action_date: Date.today, account_name: "LIFESTYLE BOOKS  MANGANGXA", user_ref: "_2055116_PAY USER"},
            { account_number: '01602117411', branch_code: '160245', account_type: "1",  amount:  "000020760.00", action_date: Date.today, account_name: "WORLD MISSION CENTRE", user_ref: "_2055115_PAY USER"},
            { account_number: '62064619962', branch_code: '256755', account_type: "1",  amount:  "000000600.00", action_date: Date.today, account_name: "JABULANI KHAKIBOS KIDS", user_ref: "_2055114_PAY USER"},
            { account_number: '04055472171', branch_code: '632005', account_type: "1",  amount:  "000000582.50", action_date: Date.today, account_name: "SURE SLIM  BENONI/SPRINGS", user_ref: "_2055113_PAY USER"},
            { account_number: '01232026794', branch_code: '123209', account_type: "1",  amount:  "000018250.00", action_date: Date.today, account_name: "TRISAVE  HAMADA", user_ref: "_2055112_PAY USER"},
            { account_number: '04042937322', branch_code: '632005', account_type: "1",  amount:  "000011071.49", action_date: Date.today, account_name: "THE GUARDIAN GROUP", user_ref: "_2055111_PAY USER"},
            { account_number: '01128016567', branch_code: '112805', account_type: "1",  amount:  "000000865.93", action_date: Date.today, account_name: "THOMSON ACCOUNTANTS", user_ref: "_2055110_PAY USER"},
            { account_number: '62071481205', branch_code: '260146', account_type: "1",  amount:  "000005580.00", action_date: Date.today, account_name: "BUYS  GENOTE MAKELAARS", user_ref: "_2055109_PAY USER"},
            { account_number: '00022750665', branch_code: '051001', account_type: "1",  amount:  "000011115.00", action_date: Date.today, account_name: "ACCOUNT N TAX CC", user_ref: "_2055108_PAY USER"},
            { account_number: '62049896246', branch_code: '211517', account_type: "1",  amount:  "000000546.57", action_date: Date.today, account_name: "FORTUIN FUNERAL HOME", user_ref: "_2055107_PAY USER"},
            { account_number: '62112480893', branch_code: '250655', account_type: "1",  amount:  "000000515.00", action_date: Date.today, account_name: "BLUE WATER", user_ref: "_2055106_PAY USER"},
            { account_number: '04048782638', branch_code: '632005', account_type: "1",  amount:  "000001497.04", action_date: Date.today, account_name: "DEO GLORIA", user_ref: "_2055105_PAY USER"},
            { account_number: '01150161831', branch_code: '632005', account_type: "1",  amount:  "000000800.00", action_date: Date.today, account_name: "PETROHOF", user_ref: "_2055104_PAY USER"},
            { account_number: '62000440173', branch_code: '250655', account_type: "1",  amount:  "000001150.00", action_date: Date.today, account_name: "BENDOR GARDENS", user_ref: "_2055103_PAY USER"},
            { account_number: '62005438470', branch_code: '257705', account_type: "1",  amount:  "000003415.00", action_date: Date.today, account_name: "POOL CLINQUE", user_ref: "_2055102_PAY USER"},
            { account_number: '05260151306', branch_code: '632005', account_type: "1",  amount:  "000033876.00", action_date: Date.today, account_name: "L/S MAGALIESKRUIN", user_ref: "_2055101_PAY USER"},
            { account_number: '01411257154', branch_code: '141148', account_type: "1",  amount:  "000000460.00", action_date: Date.today, account_name: "VIDA COURT", user_ref: "_2055100_PAY USER"},
            { account_number: '62093414242', branch_code: '250655', account_type: "1",  amount:  "000000560.00", action_date: Date.today, account_name: "VILLA MERZEE", user_ref: "_2055099_PAY USER"},
            { account_number: '62149866222', branch_code: '250655', account_type: "1",  amount:  "000000694.80", action_date: Date.today, account_name: "VILLA TIMONICE", user_ref: "_2055098_PAY USER"},
            { account_number: '54200045473', branch_code: '260347', account_type: "1",  amount:  "000008839.20", action_date: Date.today, account_name: "UNICORN SECURITY", user_ref: "_2055097_PAY USER"},
            { account_number: '62101679994', branch_code: '252145', account_type: "1",  amount:  "000010120.00", action_date: Date.today, account_name: "GLOBAL MISSIONS", user_ref: "_2055096_PAY USER"},
            { account_number: '00221501223', branch_code: '051001', account_type: "1",  amount:  "000001760.00", action_date: Date.today, account_name: "WIZARDWORX", user_ref: "_2055095_PAY USER"},
            { account_number: '04043978795', branch_code: '632005', account_type: "1",  amount:  "000001720.00", action_date: Date.today, account_name: "WA PIETERS  ASS", user_ref: "_2055094_PAY USER"},
            { account_number: '04048580705', branch_code: '632005', account_type: "1",  amount:  "000000600.00", action_date: Date.today, account_name: "ZOE ACADEMY", user_ref: "_2055093_PAY USER"},
            { account_number: '00020803907', branch_code: '051001', account_type: "1",  amount:  "000043320.00", action_date: Date.today, account_name: "ELTRA AFRICA CC", user_ref: "_2055092_PAY USER"},
            { account_number: '00235787396', branch_code: '051001', account_type: "1",  amount:  "000002545.22", action_date: Date.today, account_name: "LIFESTYLE BOOKS  BANDA", user_ref: "_2055091_PAY USER"},
            { account_number: '09083437516', branch_code: '632005', account_type: "1",  amount:  "000006000.00", action_date: Date.today, account_name: "HUIS OEBOENTOE", user_ref: "_2055090_PAY USER"},
            { account_number: '04070648490', branch_code: '632005', account_type: "1",  amount:  "000010092.00", action_date: Date.today, account_name: "BLOEM SELF STORAGE", user_ref: "_2055089_PAY USER"},
            { account_number: '01030660109', branch_code: '632005', account_type: "1",  amount:  "000011176.00", action_date: Date.today, account_name: "HENSTOCK VAN DEN HEEVER", user_ref: "_2055088_PAY USER"},
            { account_number: '01411238753', branch_code: '141148', account_type: "1",  amount:  "000001085.00", action_date: Date.today, account_name: "ADENHOF", user_ref: "_2055087_PAY USER"},
            { account_number: '00021199418', branch_code: '051001', account_type: "1",  amount:  "000008140.00", action_date: Date.today, account_name: "KUMON  SHEARER", user_ref: "_2055086_PAY USER"},
            { account_number: '60036499560', branch_code: '212217', account_type: "1",  amount:  "000003600.00", action_date: Date.today, account_name: "MF ACCOUTING  BOOKKEEPING SER", user_ref: "_2055085_PAY USER"},
            { account_number: '01028411045', branch_code: '632005', account_type: "1",  amount:  "000001757.00", action_date: Date.today, account_name: "LIFESTYLE BOOKS BARNARD", user_ref: "_2055084_PAY USER"},
            { account_number: '01627024328', branch_code: '162734', account_type: "1",  amount:  "000004790.00", action_date: Date.today, account_name: "STORAGE CITY", user_ref: "_2055083_PAY USER"},
            { account_number: '04057772276', branch_code: '632005', account_type: "1",  amount:  "000001269.85", action_date: Date.today, account_name: "POOL MAGIC", user_ref: "_2055082_PAY USER"},
            { account_number: '01662054092', branch_code: '162734', account_type: "1",  amount:  "000000600.00", action_date: Date.today, account_name: "CONCERNED EMPLOYERS ASSOCIATI", user_ref: "_2055081_PAY USER"},
            { account_number: '01904176003', branch_code: '190442', account_type: "1",  amount:  "000003230.00", action_date: Date.today, account_name: "POOL MAGIC ADVISORY", user_ref: "_2055080_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000149.00", action_date: Date.today, account_name: "RWFL GRAHAMSTOWN", user_ref: "_2055079_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000829.33", action_date: Date.today, account_name: "RWFL SHARONLEE", user_ref: "_2055078_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000120.90", action_date: Date.today, account_name: "RWFL TABLEVIEW", user_ref: "_2055077_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000629.13", action_date: Date.today, account_name: "RWFL  OUDTSHOORM", user_ref: "_2055076_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000332.83", action_date: Date.today, account_name: "RWFL  HILTON", user_ref: "_2055075_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000001018.12", action_date: Date.today, account_name: "RWFL  DIE MOOT", user_ref: "_2055074_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000423.00", action_date: Date.today, account_name: "RWFL  MODDERFONTEIN", user_ref: "_2055073_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000221.02", action_date: Date.today, account_name: "RWFL  PRETORIA NORTH", user_ref: "_2055072_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000126.55", action_date: Date.today, account_name: "RWFL  BRAKPAN", user_ref: "_2055071_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000002787.04", action_date: Date.today, account_name: "RWFL  RUSTENBURG", user_ref: "_2055070_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000314.87", action_date: Date.today, account_name: "RWFL  WELTEVREDENPARK AM  PM", user_ref: "_2055069_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000119.00", action_date: Date.today, account_name: "RWFL  SANDTON AM  PM", user_ref: "_2055068_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000378.82", action_date: Date.today, account_name: "RWFL  ROODEPOORT PM  KRUGERS", user_ref: "_2055067_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000933.64", action_date: Date.today, account_name: "RWFL  RANDBURG PM", user_ref: "_2055066_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000252.05", action_date: Date.today, account_name: "RWFL  NORTHCLIFF PM", user_ref: "_2055065_PAY USER"},
            { account_number: '62005080388', branch_code: '990355', account_type: "1",  amount:  "000000200.00", action_date: Date.today, account_name: "RWFL  MILNERTON PM", user_ref: "_2055064_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000605.15", action_date: Date.today, account_name: "RWFL  MIDRAND PM", user_ref: "_2055063_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000756.14", action_date: Date.today, account_name: "RWFL  KEMPTON PARK PM", user_ref: "_2055062_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000171.12", action_date: Date.today, account_name: "RWFL  GARSFONTEIN PM", user_ref: "_2055061_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000780.84", action_date: Date.today, account_name: "RWFL  GERMISTON PM", user_ref: "_2055060_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000193.45", action_date: Date.today, account_name: "RWFL  FISH HOEK PM", user_ref: "_2055059_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000126.55", action_date: Date.today, account_name: "RWFL  FOURWAYS PM", user_ref: "_2055058_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000001210.19", action_date: Date.today, account_name: "RWFL  EAST LONDON AM", user_ref: "_2055057_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000096.45", action_date: Date.today, account_name: "RWFL  ELARDUS PARK PM", user_ref: "_2055056_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000306.07", action_date: Date.today, account_name: "RWFL  EDENVALE PM", user_ref: "_2055055_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000101.82", action_date: Date.today, account_name: "RWFL  CENTURION PM  THE WILL", user_ref: "_2055054_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000071.45", action_date: Date.today, account_name: "RWFL  BELLVILLE AM", user_ref: "_2055053_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000252.33", action_date: Date.today, account_name: "RWFL  BRYANSTON PM  RANDBURG", user_ref: "_2055052_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000175.30", action_date: Date.today, account_name: "RWFL  BERGVLIET PM", user_ref: "_2055051_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000327.00", action_date: Date.today, account_name: "RWFL  BEDFORDVIEW PM  EDENVA", user_ref: "_2055050_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000126.70", action_date: Date.today, account_name: "RWFL  BRYANSTON AM  SUNNINGH", user_ref: "_2055049_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000439.77", action_date: Date.today, account_name: "RWFL  BROOKLYN PM", user_ref: "_2055048_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000001374.11", action_date: Date.today, account_name: "RWFL  BOKSBURG PM/BEDFRODVIE", user_ref: "_2055047_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000681.08", action_date: Date.today, account_name: "RWFL  AMANZINTOTI/BEREA", user_ref: "_2055046_PAY USER"},
            { account_number: '62005080388', branch_code: '250355', account_type: "1",  amount:  "000000861.27", action_date: Date.today, account_name: "RWFL  ALBERTON/GLENVISTA", user_ref: "_2055045_PAY USER"},
            { account_number: '01128016575', branch_code: '112805', account_type: "1",  amount:  "000001900.00", action_date: Date.today, account_name: "THOMSON ACCOUNTANTS", user_ref: "_2055044_PAY USER"},
            { account_number: '01128016575', branch_code: '112805', account_type: "1",  amount:  "000000860.00", action_date: Date.today, account_name: "THOMSON ACCOUNTANTS", user_ref: "_2055043_PAY USER"},
            { account_number: '01983141100', branch_code: '198341', account_type: "1",  amount:  "000032766.97", action_date: Date.today, account_name: "DUNMAR REACTION SERVICES", user_ref: "_2055042_PAY USER"},
            { account_number: '04061717092', branch_code: '632005', account_type: "1",  amount:  "000049445.00", action_date: Date.today, account_name: "TEXTILE SECURITY SERVICES", user_ref: "_2055041_PAY USER"},
            { account_number: '52104226149', branch_code: '260449', account_type: "1",  amount:  "000000300.00", action_date: Date.today, account_name: "DR SPIES  VENNOTE", user_ref: "_2055040_PAY USER"},
            { account_number: '62096195344', branch_code: '260349', account_type: "1",  amount:  "000000755.00", action_date: Date.today, account_name: "TOP COUNCILS LEGAL CONSUNTANC", user_ref: "_2055039_PAY USER"},
            { account_number: '02140264523', branch_code: '632005', account_type: "1",  amount:  "000001000.00", action_date: Date.today, account_name: "SIGMAFIN", user_ref: "_2055038_PAY USER"},
            { account_number: '02840000365', branch_code: '632005', account_type: "1",  amount:  "000000830.00", action_date: Date.today, account_name: "UJ GYM", user_ref: "_2055037_PAY USER"},
            { account_number: '04055281954', branch_code: '632005', account_type: "1",  amount:  "000001930.77", action_date: Date.today, account_name: "CENTRE SHELF DEVELOPERS T/A E", user_ref: "_2055036_PAY USER"},
            { account_number: '62062107711', branch_code: '261251', account_type: "1",  amount:  "000000399.00", action_date: Date.today, account_name: "MOTO GUIDE CC", user_ref: "_2055035_PAY USER"},
            { account_number: '00078262496', branch_code: '026509', account_type: "1",  amount:  "000000200.00", action_date: Date.today, account_name: "IMPACT THE NATION", user_ref: "_2055034_PAY USER"},
            { account_number: '04070619188', branch_code: '632005', account_type: "1",  amount:  "000048729.90", action_date: Date.today, account_name: "HENTIQ 2227 PTY LTD", user_ref: "_2055033_PAY USER"},
            { account_number: '62115276603', branch_code: '261251', account_type: "1",  amount:  "000049935.00", action_date: Date.today, account_name: "EVEREST STRATEGIC MANAGERS PT", user_ref: "_2055032_PAY USER"},
            { account_number: '04057512949', branch_code: '632005', account_type: "1",  amount:  "000000566.00", action_date: Date.today, account_name: "DIGITAL IP SOLUTIONS PTY LTD", user_ref: "_2055031_PAY USER"},
            { account_number: '00021158932', branch_code: '015641', account_type: "1",  amount:  "000013488.00", action_date: Date.today, account_name: "E MALAN  ASS CC", user_ref: "_2055030_PAY USER"},
            { account_number: '00030235642', branch_code: '051001', account_type: "1",  amount:  "000002562.10", action_date: Date.today, account_name: "METHODIST CHURCH", user_ref: "_2055029_PAY USER"},
            { account_number: '00221015566', branch_code: '018005', account_type: "1",  amount:  "000049161.93", action_date: Date.today, account_name: "HEALING MINISTRIES TRUST", user_ref: "_2055028_PAY USER"},
            { account_number: '00200589458', branch_code: '006305', account_type: "1",  amount:  "000000473.00", action_date: Date.today, account_name: "WILLEMS  VD WESTHUIZEN", user_ref: "_2055027_PAY USER"},
            { account_number: '62032469836', branch_code: '252045', account_type: "1",  amount:  "000003142.50", action_date: Date.today, account_name: "COMPACT ACCOUNTING", user_ref: "_2055026_PAY USER"},
            { account_number: '01651343144', branch_code: '165145', account_type: "1",  amount:  "000000865.03", action_date: Date.today, account_name: "BOSHOFF SMUTS ING", user_ref: "_2055025_PAY USER"}
          ]
        }]
      }
    })                                                                                                                                
  end                                                                                                                                 
end                                                                                                                                   
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      
                                                                                                                                      